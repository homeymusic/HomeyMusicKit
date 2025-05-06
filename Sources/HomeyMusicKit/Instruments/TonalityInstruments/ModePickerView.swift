import SwiftUI

public struct ModePickerInstrumentView: Identifiable, View {
    @Bindable public var tonalityInstrument: TonalityInstrument
    
    @State private var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]

    public let id = UUID()
    
    public var body: some View {
        ZStack {
            ModePickerView(tonalityInstrument: tonalityInstrument)
            MultiTouchOverlayView { touches in
                setMIDINoteNumberLocations(
                    touches,
                    tonalityInstrument: tonalityInstrument
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
    public func setMIDINoteNumberLocations(_ touchPoints: [CGPoint], tonalityInstrument: TonalityInstrument) {
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
                    if tonalityInstrument.areModeAndTonicLinked && tonalityInstrument.isAutoModeAndTonicEnabled {
                        let oldDirection = tonalityInstrument.mode.pitchDirection
                        let newDirection = m.pitchDirection
                        switch (oldDirection, newDirection) {
                        case (.mixed, .downward):
                            tonalityInstrument.shiftUpOneOctave()
                        case (.upward, .downward):
                            tonalityInstrument.shiftUpOneOctave()
                        case (.downward, .upward):
                            tonalityInstrument.shiftDownOneOctave()
                        case (.downward, .mixed):
                            tonalityInstrument.shiftDownOneOctave()
                        default:
                            break
                        }
                    }
                    withAnimation {
                        updateMode(m, tonalityInstrument: tonalityInstrument)
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
                            tonalityInstrument: TonalityInstrument) {
        if newMode != tonalityInstrument.mode {
            if tonalityInstrument.areModeAndTonicLinked && tonalityInstrument.isAutoModeAndTonicEnabled {
                let modeDiff = modulo(newMode.rawValue - tonalityInstrument.mode.rawValue, 12)
                let tonicMIDINumber: Int = Int(tonalityInstrument.tonicPitch.midiNote.number) + modeDiff
                if Pitch.isValid(tonicMIDINumber) {
                    tonalityInstrument.tonicPitch = tonalityInstrument.pitch(for: MIDINoteNumber(tonicMIDINumber))
                } else {
                    fatalError("INVALID TONIC in updateMode in tonicPicker!!")
                }
                let oldDirection = tonalityInstrument.mode.pitchDirection
                let newDirection = newMode.pitchDirection
                switch (oldDirection, newDirection) {
                case (.upward, .downward):
                    tonalityInstrument.shiftDownOneOctave()
                    break
                case (.downward, .upward):
                    break
                case (.upward, .upward):
                    break
                case (.mixed, .downward):
                    tonalityInstrument.shiftDownOneOctave()
                    break
                case (.downward, .downward):
                    tonalityInstrument.shiftDownOneOctave()
                    break
                case (.mixed, .upward):
                    break
                default:
                    break
                }
                if tonalityInstrument.pitchDirection != newMode.pitchDirection {
                    tonalityInstrument.pitchDirection = newMode.pitchDirection
                }
            }
            tonalityInstrument.mode = newMode
            buzz()
        }
    }

}

struct ModePickerView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalityInstrument.modeInts.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    instrument: tonalityInstrument,
                    mode: mode,
                    row: row,
                    col: col
                )
                .id(mode.rawValue)
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
