import SwiftUI

public struct TonicInstrumentView: Identifiable, View {
    let tonicPicker: TonicPicker
    @State private var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]

    public init(tonicPicker: TonicPicker) {
        self.tonicPicker = tonicPicker
    }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView(tonicPicker: tonicPicker)
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
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
    }
    
    @State private var isTonicLocked = false
    public func setMIDINoteNumberLocations(_ touchPoints: [CGPoint], tonicPicker: TonicPicker) {
        for touchPoint in touchPoints {
            var tonicPitch: Pitch?
            for info in midiNoteNumberOverlayCells.values where info.rect.contains(touchPoint) {
                if tonicPitch == nil {
                    tonicPitch = tonicPicker.pitch(for: MIDINoteNumber(info.identifier))
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    withAnimation {
                        updateTonic(tonicPitch: t, tonicPicker: tonicPicker)
                    }
                    isTonicLocked = true
                }
            }
        }
        
        if touchPoints.isEmpty {
            isTonicLocked = false
        }
    }
    
    public func updateTonic(tonicPitch: Pitch, tonicPicker: TonicPicker) {
        buzz()

        if tonicPicker.pitchDirection == .mixed {
            if tonicPitch == tonicPicker.tonicPitch {
                tonicPicker.shiftDownOneOctave()
                buzz()
                return
            } else if tonicPitch.isOctave(relativeTo: tonicPicker.tonicPitch) {
                tonicPicker.shiftUpOneOctave()
                return
            }
        }

        if tonicPitch.isOctave(relativeTo: tonicPicker.tonicPitch) {
            if tonicPitch.midiNote.number > tonicPicker.tonicPitch.midiNote.number {
                tonicPicker.pitchDirection = .downward
            } else {
                tonicPicker.pitchDirection = .upward
            }
            tonicPicker.tonicPitch = tonicPitch
            return
        } else {
            if tonicPicker.areModeAndTonicLinked && tonicPicker.isAutoModeAndTonicEnabled {
                let newMode: Mode = Mode(
                    rawValue: modulo(
                        tonicPicker.mode.rawValue + Int(tonicPitch.distance(from: tonicPicker.tonicPitch)), 12
                    ))!

                tonicPicker.tonicPitch = tonicPitch

                if newMode != tonicPicker.mode {
                    let oldDirection = tonicPicker.mode.pitchDirection
                    let newDirection = newMode.pitchDirection
                    switch (oldDirection, newDirection) {
                    case (.upward, .downward):
                        break
                    case (.downward, .upward):
                        break
                    case (.upward, .upward):
                        break
                    case (.mixed, .downward):
                        break
                    case (.downward, .downward):
                        break
                    case (.mixed, .upward):
                        break
                    default:
                        break
                    }

                    tonicPicker.mode = newMode
                    tonicPicker.pitchDirection = newMode.pitchDirection
                }
            } else {
                tonicPicker.tonicPitch = tonicPitch
            }
            return
        }
    }
    


}
