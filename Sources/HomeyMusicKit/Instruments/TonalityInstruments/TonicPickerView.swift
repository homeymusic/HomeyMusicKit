import SwiftUI

public struct TonicPickerInstrumentView: Identifiable, View {
    @Bindable public var tonalityInstrument: TonalityInstrument
    
    @State private var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView(tonalityInstrument: tonalityInstrument)
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
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
    }
    
    @State private var isTonicLocked = false
    public func setMIDINoteNumberLocations(_ touchPoints: [CGPoint], tonalityInstrument: TonalityInstrument) {
        for touchPoint in touchPoints {
            var tonicPitch: Pitch?
            for info in midiNoteNumberOverlayCells.values where info.rect.contains(touchPoint) {
                if tonicPitch == nil {
                    tonicPitch = tonalityInstrument.pitch(for: MIDINoteNumber(info.identifier))
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    withAnimation {
                        updateTonic(tonicPitch: t, tonalityInstrument: tonalityInstrument)
                    }
                    isTonicLocked = true
                }
            }
        }
        
        if touchPoints.isEmpty {
            isTonicLocked = false
        }
    }
    
    public func updateTonic(tonicPitch: Pitch, tonalityInstrument: TonalityInstrument) {
        buzz()
        
        if tonalityInstrument.pitchDirection == .mixed {
            if tonicPitch == tonalityInstrument.tonicPitch {
                tonalityInstrument.shiftDownOneOctave()
                buzz()
                return
            } else if tonicPitch.isOctave(relativeTo: tonalityInstrument.tonicPitch) {
                tonalityInstrument.shiftUpOneOctave()
                return
            }
        }
        
        if tonicPitch.isOctave(relativeTo: tonalityInstrument.tonicPitch) {
            if tonicPitch.midiNote.number > tonalityInstrument.tonicPitch.midiNote.number {
                tonalityInstrument.pitchDirection = .downward
            } else {
                tonalityInstrument.pitchDirection = .upward
            }
            
            tonalityInstrument.tonicPitch = tonicPitch
            return
        } else {
            if tonalityInstrument.areModeAndTonicLinked && tonalityInstrument.isAutoModeAndTonicEnabled {
                let newMode: Mode = Mode(
                    rawValue: modulo(
                        tonalityInstrument.mode.rawValue + Int(tonicPitch.distance(from: tonalityInstrument.tonicPitch)), 12
                    ))!
                tonalityInstrument.tonicPitch = tonicPitch
                
                if newMode != tonalityInstrument.mode {
                    let oldDirection = tonalityInstrument.mode.pitchDirection
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
                    
                    tonalityInstrument.mode = newMode
                    tonalityInstrument.pitchDirection = newMode.pitchDirection
                }
            } else {
                tonalityInstrument.tonicPitch = tonicPitch
            }
            return
        }
    }
    
}

struct TonicPickerView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalityInstrument.availableMIDINoteInts.enumerated()), id: \.offset) { col, midiNoteInt in
                if Pitch.isValid(midiNoteInt) {
                    let pitch = tonalityInstrument.pitch(for: MIDINoteNumber(midiNoteInt))
                    PitchCell(
                        pitch: pitch,
                        instrument: tonalityInstrument,
                        row: row,
                        col: col,
                        cellType: .basic,
                        namedCoordinateSpace: HomeyMusicKit.tonicPickerSpace
                    )
                    .id(pitch.midiNote.number)
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonalityInstrument.tonicPitch)
    }
}
