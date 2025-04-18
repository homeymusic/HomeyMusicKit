import SwiftUI

@MainActor
@Observable
public final class Orchestrator {
    // MARK: - Public Properties
    
    public var instrumentalContext: InstrumentalContext
    public var tonalContext: TonalContext
    public var notationalContext: NotationalContext
    public var notationalTonicContext: NotationalTonicContext
    public var midiConductor: MIDIConductor
    public var synthConductor: SynthConductor
    private var cachedPitches: [Pitch] = []
    // MARK: - Initialization
    
    /// The init allocates all components, but doesn't wire them up yet.
    public init() {
        self.instrumentalContext = InstrumentalContext()
        self.tonalContext = TonalContext()
        self.notationalContext = NotationalContext()
        self.notationalTonicContext = NotationalTonicContext()
        self.synthConductor = SynthConductor()
        
        self.midiConductor = MIDIConductor(
            clientName: "HomeyPad",
            model: "Homey Pad iOS",
            manufacturer: "Homey Music"
        )
    }
    
    // MARK: - Setup / Wiring
    
    /// Wires up callbacks between the contexts and the MIDIConductor, then starts MIDI services.
    @discardableResult
    public func setup() -> Orchestrator {
        
        // 1) Start MIDI services:
        midiConductor.setup()
        
        // 2) TonalContext -> MIDIConductor + Synth.
        //    We pass the "instrumentChoice" channel whenever sending noteOn/noteOff.
        
        for pitch in tonalContext.allPitches {
            pitch.onActivationChanged = { [weak self] pitch, isActivated in
                guard let self = self else { return }
                
                if isActivated {
                    // First, synth note on
                    self.synthConductor.noteOn(pitch: pitch)
                    // Then, send the MIDI note on to the chosen channel
                    self.midiConductor.noteOn(
                        pitch: pitch,
                        channel: self.instrumentalContext.instrumentChoice.rawValue
                    )
                } else {
                    self.synthConductor.noteOff(pitch: pitch)
                    self.midiConductor.noteOff(
                        pitch: pitch,
                        channel: self.instrumentalContext.instrumentChoice.rawValue
                    )
                }
            }
        }
        
        instrumentalContext.beforeInstrumentChange = { [weak self] instrumentChoice in
            guard let self = self else { return }
            self.cachedPitches = tonalContext.activatedPitches
            for pitch in tonalContext.activatedPitches {
                pitch.deactivate()
            }
         }

        instrumentalContext.afterInstrumentChange = { [weak self] instrumentChoice in
            guard let self = self else { return }
            if instrumentalContext.latching {
                for pitch in self.cachedPitches {
                    pitch.activate()
                }
            }
            self.cachedPitches = []
         }

        instrumentalContext.onLatchingChanged = { [weak self] latching in
            guard let self = self else { return }
            if !latching {
                for pitch in tonalContext.activatedPitches {
                    pitch.deactivate()
                }
            }
         }
                
        tonalContext.onTonicPitchChanged = { [weak self] newTonicPitch in
            guard let self = self else { return }
            // Send the updated tonic pitch on the "tonic picker" channel
            self.midiConductor.tonicPitch(
                newTonicPitch,
                channel: InstrumentChoice.tonicPicker.rawValue
            )
        }
        
        tonalContext.onPitchDirectionChanged = { [weak self] newDirection in
            guard let self = self else { return }
            self.midiConductor.pitchDirection(
                newDirection,
                channel: InstrumentChoice.tonicPicker.rawValue
            )
        }
        
        tonalContext.onModeChanged = { [weak self] newMode in
            guard let self = self else { return }
            self.midiConductor.mode(
                newMode,
                channel: InstrumentChoice.modePicker.rawValue
            )
        }
        
        // 3) MIDIConductor -> TonalContext
        //    If we receive a note on/off from external MIDI, we activate/deactivate those pitches:
        
        midiConductor.onNoteOnReceived = { [weak self] noteNumber in
            guard let self = self else { return }
            let pitch = self.tonalContext.pitch(for: noteNumber)
            pitch.activate()
        }
        
        midiConductor.onNoteOffReceived = { [weak self] noteNumber in
            guard let self = self else { return }
            let pitch = self.tonalContext.pitch(for: noteNumber)
            pitch.deactivate()
        }
        
        midiConductor.onTonicPitchReceived = { [weak self] midiValue in
            guard let self = self else { return }
            let pitch = self.tonalContext.pitch(for: midiValue)
            self.tonalContext.tonicPitch = pitch
        }
        
        midiConductor.onPitchDirectionReceived = { [weak self] rawValue in
            guard let self = self else { return }
            if let direction = PitchDirection(rawValue: Int(rawValue)) {
                self.tonalContext.pitchDirection = direction
            }
        }
        
        midiConductor.onModeReceived = { [weak self] rawValue in
            guard let self = self else { return }
            if let mode = Mode(rawValue: Int(rawValue)) {
                self.tonalContext.mode = mode
            }
        }
        
        midiConductor.onStatusRequestReceived = { [weak self] in
            guard let self = self else { return }
            
            // Another device asked for our current status:
            // Send the current TonalContext to that device on the "tonic picker" channel:
            self.midiConductor.tonicPitch(
                self.tonalContext.tonicPitch,
                channel: InstrumentChoice.tonicPicker.rawValue
            )
            self.midiConductor.pitchDirection(
                self.tonalContext.pitchDirection,
                channel: InstrumentChoice.tonicPicker.rawValue
            )
            self.midiConductor.mode(
                self.tonalContext.mode,
                channel: InstrumentChoice.modePicker.rawValue
            )
        }
        
        return self
    }
}
