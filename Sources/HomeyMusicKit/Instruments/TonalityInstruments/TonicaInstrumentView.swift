import SwiftUI

public struct TonicaInstrumentView: Identifiable, View {
    let tonica: Tonica
    @State private var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    
    public init(tonica: Tonica) {
        self.tonica = tonica
    }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicaView(tonica: tonica)
            MultiTouchOverlayView { touches in
                setMIDINoteNumberLocations(
                    touches,
                    tonica: tonica
                )
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { overlayCellKey in
            Task { @MainActor in
                midiNoteNumberOverlayCells = overlayCellKey
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicaSpace)
    }
    
    @State private var isTonicLocked = false
    public func setMIDINoteNumberLocations(_ touchPoints: [CGPoint], tonica: Tonica) {
        for touchPoint in touchPoints {
            var tonicPitch: Pitch?
            for info in midiNoteNumberOverlayCells.values where info.rect.contains(touchPoint) {
                if tonicPitch == nil {
                    tonicPitch = tonica.tonality.pitch(for: MIDINoteNumber(info.identifier))
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    withAnimation {
                        updateTonic(tonicPitch: t, tonica: tonica)
                    }
                    isTonicLocked = true
                }
            }
        }
        
        if touchPoints.isEmpty {
            isTonicLocked = false
        }
    }
    
    public func updateTonic(tonicPitch: Pitch, tonica: Tonica) {
        buzz()
        
        if tonica.tonality.pitchDirection == .mixed {
            if tonicPitch == tonica.tonality.tonicPitch {
                tonica.tonality.shiftDownOneOctave()
                buzz()
                return
            } else if tonicPitch.isOctave(relativeTo: tonica.tonality.tonicPitch) {
                tonica.tonality.shiftUpOneOctave()
                return
            }
        }
        
        if tonicPitch.isOctave(relativeTo: tonica.tonality.tonicPitch) {
            if tonicPitch.midiNote.number > tonica.tonality.tonicPitch.midiNote.number {
                tonica.tonality.pitchDirection = .downward
            } else {
                tonica.tonality.pitchDirection = .upward
            }
            tonica.tonality.tonicPitch = tonicPitch
            return
        } else {
            if tonica.areModeAndTonicLinked && tonica.isAutoModeAndTonicEnabled {
                let newMode: Mode = Mode(
                    rawValue: modulo(
                        tonica.tonality.mode.rawValue + Int(tonicPitch.distance(from: tonica.tonality.tonicPitch)), 12
                    ))!
                
                tonica.tonality.tonicPitch = tonicPitch
                
                if newMode != tonica.tonality.mode {
                    let oldDirection = tonica.tonality.mode.pitchDirection
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
                    
                    tonica.tonality.mode = newMode
                    tonica.tonality.pitchDirection = newMode.pitchDirection
                }
            } else {
                tonica.tonality.tonicPitch = tonicPitch
            }
            return
        }
    }
    
}
