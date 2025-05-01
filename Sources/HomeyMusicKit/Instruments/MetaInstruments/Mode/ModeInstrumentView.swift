import SwiftUI

public struct ModeInstrumentView: Identifiable, View {
    let tonicPicker: TonicPicker
    @State private var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]

    public init(tonicPicker: TonicPicker) {
        self.tonicPicker = tonicPicker
    }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            ModePickerView(tonicPicker: tonicPicker)
            MultiTouchOverlayView { touches in
                setMIDINoteNumberLocations(
                    touches,
                    tonicPicker: tonicPicker
                )
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { overlayCellKey in
            Task { @MainActor in
                midiNoteNumberOverlayCells = overlayCellKey
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
    
    @State private var isModeLocked = false
    public func setMIDINoteNumberLocations(_ touchPoints: [CGPoint], tonicPicker: TonicPicker) {
        for touchPoint in touchPoints {
            var mode: Mode?
            
            // Find the pitch at this location with the highest Z-index
            for info in midiNoteNumberOverlayCells.values where info.rect.contains(touchPoint) {
                if mode == nil {
                    mode = Mode(rawValue: info.identifier)
                }
            }
            
            if let m = mode {
                if !isModeLocked {
                    if tonicPicker.areModeAndTonicLinked && tonicPicker.isAutoModeAndTonicEnabled {
                        let oldDirection = tonicPicker.mode.pitchDirection
                        let newDirection = m.pitchDirection
                        switch (oldDirection, newDirection) {
                        case (.mixed, .downward):
                            tonicPicker.shiftUpOneOctave()
                        case (.upward, .downward):
                            tonicPicker.shiftUpOneOctave()
                        case (.downward, .upward):
                            tonicPicker.shiftDownOneOctave()
                        case (.downward, .mixed):
                            tonicPicker.shiftDownOneOctave()
                        default:
                            break
                        }
                    }
                    withAnimation {
                        updateMode(m, tonicPicker: tonicPicker)
                    }
                    isModeLocked = true
                }
            }
        }
        
        if touchPoints.isEmpty {
            isModeLocked = false
        }
    }
    
    private func updateMode(_ newMode: Mode,
                            tonicPicker: TonicPicker) {
        if newMode != tonicPicker.mode {
            if tonicPicker.areModeAndTonicLinked && tonicPicker.isAutoModeAndTonicEnabled {
                let modeDiff = modulo(newMode.rawValue - tonicPicker.mode.rawValue, 12)
                let tonicMIDINumber: Int = Int(tonicPicker.tonicPitch.midiNote.number) + modeDiff
                if Pitch.isValid(tonicMIDINumber) {
                    tonicPicker.tonicPitch = tonicPicker.pitch(for: MIDINoteNumber(tonicMIDINumber))
                } else {
                    fatalError("INVALID TONIC in updateMode in tonicPicker!!")
                }
                let oldDirection = tonicPicker.mode.pitchDirection
                let newDirection = newMode.pitchDirection
                switch (oldDirection, newDirection) {
                case (.upward, .downward):
                    tonicPicker.shiftDownOneOctave()
                    break
                case (.downward, .upward):
                    break
                case (.upward, .upward):
                    break
                case (.mixed, .downward):
                    tonicPicker.shiftDownOneOctave()
                    break
                case (.downward, .downward):
                    tonicPicker.shiftDownOneOctave()
                    break
                case (.mixed, .upward):
                    break
                default:
                    break
                }
                if tonicPicker.pitchDirection != newMode.pitchDirection {
                    tonicPicker.pitchDirection = newMode.pitchDirection
                }
            }
            tonicPicker.mode = newMode
            buzz()
        }
    }

}
