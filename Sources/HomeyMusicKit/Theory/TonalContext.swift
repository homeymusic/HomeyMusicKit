import MIDIKitCore
import MIDIKit
import SwiftUI

@MainActor
public class TonalContext: ObservableObject, @unchecked Sendable  {
    // Singleton instance
    public static let shared = TonalContext()
    
    @Published public var activatedPitches: Set<Pitch> = []
    
    // Allow injection of custom MIDI and Synth conductors for testing
    public var midiConductor: MIDIConductorProtocol
    public var synthConductor: SynthConductorProtocol

    // State Manager to handle saving/loading
    private let defaultsManager = TonalContextDefaultsManager()
    
    @Published public var tonicPitch: Pitch {
        didSet {
            if oldValue != tonicPitch {
                buzz()
                midiConductor.sendTonicPitch(midiNote: tonicPitch.midiNote, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    @Published public var pitchDirection: PitchDirection {
        didSet {
            if oldValue != pitchDirection {
                buzz()
                adjustTonicPitchForDirectionChange(from: oldValue, to: pitchDirection)
                midiConductor.sendPitchDirection(upwardPitchDirection: pitchDirection == .upward,
                                                  midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    // Function to check if shifting up one octave is valid
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValidPitch(Int(tonicMIDI) + 12)
    }

    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValidPitch(Int(tonicMIDI) - 12)
    }

    // Function to shift up one octave, returning the pitch from allPitches
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = Pitch.pitch(for: tonicMIDI + 12)
        }
    }

    // Function to shift down one octave, returning the pitch from allPitches
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = Pitch.pitch(for: tonicMIDI - 12)
        }
    }
    
    // Computed property to determine the octave shift
    public var octaveShift: Int {
        let midi = if pitchDirection == .upward || !canShiftDownOneOctave {
            self.tonicMIDI
        } else {
            self.tonicMIDI - 12
        }
        return Pitch.pitch(for: midi).octave - 4
    }
    
    private func adjustTonicPitchForDirectionChange(from oldDirection: PitchDirection, to newDirection: PitchDirection) {
        if oldDirection != newDirection {
            switch (oldDirection, newDirection) {
            case (.upward, .downward):
                shiftUpOneOctave()
            case (.downward, .upward):
                shiftDownOneOctave()
            default:
                break
            }
        }
    }
    
    private init(
        midiConductor: MIDIConductorProtocol = MIDIConductor(sendCurrentState: {}),
        synthConductor: SynthConductorProtocol = SynthConductor()
    ) {
        self.midiConductor = midiConductor
        self.synthConductor = synthConductor

        // Load state and initialize tonic and pitchDirection
        let savedState = defaultsManager.loadState(allPitches: Pitch.allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection

        defaultsManager.bindAndSave(tonalContext: self)
    }

    public func reloadAudio() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.synthConductor.engine.avEngine.isRunning {
                self.synthConductor.start()
            }
        }
    }

    func sendCurrentState() {
        midiConductor.sendTonicPitch(midiNote: tonicPitch.midiNote, midiChannel: LayoutChoice.tonic.midiChannel())
        midiConductor.sendPitchDirection(upwardPitchDirection: pitchDirection == .upward, midiChannel: LayoutChoice.tonic.midiChannel())
    }
    
    let midiManager = ObservableMIDIManager(
        clientName: "HomeyMusicKit",
        model: "iOS",
        manufacturer: "Homey Music"
    )
    
    public func resetToDefault() {
        resetPitchDirection()
        resetTonicPitch()
    }
    
    public var isDefault: Bool {
        self.isDefaultTonicPitch && self.isDefaultPitchDirection
    }
    
    public var isDefaultTonicPitch: Bool {
        self.tonicPitch.midiNote.number == Pitch.defaultTonicMIDI
    }
    
    public var isDefaultPitchDirection: Bool {
        self.pitchDirection == PitchDirection.default
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = Pitch.pitch(for: Pitch.defaultTonicMIDI) // Reset to default pitch
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }
    
    public var tonicRegisterNotes: ClosedRange<Int> {
        let tonicNote = Int(tonicMIDI)
        return pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var tonicMIDI: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
    public var nearestValidTritoneMIDI: MIDINoteNumber {
        let offset: IntervalNumber = (pitchDirection == .downward) ? -6 : 6
        
        // Try to return the primary tritone if valid, otherwise return the opposite tritone
        if let validPrefferedTritone = MIDINoteNumber(exactly: IntervalNumber(tonicMIDI) + offset) {
            return validPrefferedTritone
        } else if let validOppositeTritone = MIDINoteNumber(exactly: IntervalNumber(tonicMIDI) - offset) {
            return validOppositeTritone
        } else {
            fatalError("Invalid tritone calculation: MIDI value out of range. Should never get here.")
        }
    }
}
