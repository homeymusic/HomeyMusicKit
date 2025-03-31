import SwiftUI

@MainActor
@Observable
public final class Orchestrator {
    public var instrumentalContext: InstrumentalContext
    public var tonalContext: TonalContext
    public var notationalContext: NotationalContext
    public var notationalTonicContext: NotationalTonicContext
    public var midiConductor: MIDIConductor
    public var synthConductor: SynthConductor

    public init() {
        // Create local instances
        let __instrumentalContext = InstrumentalContext()
        let __tonalContext = TonalContext()
        let __synthConductor = SynthConductor()

        // Create a local instance of MIDIConductor
        let __midiConductor = MIDIConductor(
            tonalContext: __tonalContext,
            instrumentMIDIChannelProvider: { __instrumentalContext.instrumentChoice.rawValue },
            tonicMIDIChannel: InstrumentChoice.tonicPicker.rawValue,
            clientName: "HomeyPad",
            model: "Homey Pad iOS",
            manufacturer: "Homey Music"
        )
        
        __midiConductor.setup() // start MIDI services
        
        for pitch in __tonalContext.allPitches {
            pitch.onActivationChanged = { pitch, isActivated in
                // Temporarily capture synthConductor strongly for testing
                let synthConductor = __synthConductor
                let midiConductor = __midiConductor
                if isActivated {
                    synthConductor.noteOn(pitch: pitch)
                    midiConductor.noteOn(pitch: pitch)
                } else {
                    synthConductor.noteOff(pitch: pitch)
                    midiConductor.noteOff(pitch: pitch)
                }
            }
        }

        // 2. Assign callbacks for context properties
        __tonalContext.onTonicPitchChanged = { newTonicPitch in
            let midiConductor = __midiConductor
            midiConductor.tonicPitch(pitch: newTonicPitch)
        }
        __tonalContext.onPitchDirectionChanged = { newPitchDirection in
            let midiConductor = __midiConductor
            midiConductor.pitchDirection(pitchDirection: newPitchDirection)
        }
        __tonalContext.onModeChanged = { newMode in
            let midiConductor = __midiConductor
            midiConductor.mode(mode: newMode)
        }
        
        self.notationalContext = NotationalContext()
        self.notationalTonicContext = NotationalTonicContext()
        // Assign them to @StateObservable properties:
        self.instrumentalContext = __instrumentalContext
        self.tonalContext = __tonalContext
        self.synthConductor = __synthConductor
        self.midiConductor = __midiConductor
    }
}
