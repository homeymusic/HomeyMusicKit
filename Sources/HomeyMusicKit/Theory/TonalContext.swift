import SwiftUI

@MainActor
public class TonalContext: ObservableObject {
    // Singleton instance
    public static let shared = TonalContext()

    // State Manager to handle saving/loading
    private let stateManager = TonalContextStateManager()

    @Published public var tonicPitch: Pitch {
        didSet {
            if oldValue != tonicPitch {
                buzz()
            }
        }
    }
    
    @Published public var pitchDirection: PitchDirection {
        didSet {
            if oldValue != pitchDirection {
                buzz()
            }
            adjustTonicPitchForDirectionChange(from: oldValue, to: pitchDirection)
        }
    }
 
    private func adjustTonicPitchForDirectionChange(from oldDirection: PitchDirection, to newDirection: PitchDirection) {
        if oldDirection != newDirection {
            switch (oldDirection, newDirection) {
            case (.upward, .downward):
                // If changing from upward to downward, increase tonicPitch by 12 (one octave)
                if MIDIHelper.isValidMIDI(note: Int(tonicPitch.midi) + 12) {
                    tonicPitch = pitch(for: tonicPitch.midi + 12)
                }
            case (.downward, .upward):
                // If changing from downward to upward, decrease tonicPitch by 12 (one octave)
                if MIDIHelper.isValidMIDI(note: Int(tonicPitch.midi) - 12) {
                    tonicPitch = pitch(for: tonicPitch.midi - 12)
                }
            default:
                break
            }
        }
    }
    
    // Private initializer for singleton pattern
    private init() {
        // Load the initial state from the state manager
        let savedState = stateManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection
        
        // Bind and save state changes
        stateManager.bindAndSave(tonalContext: self)
    }

    public func resetToDefault() {
        resetPitchDirection()
        resetTonicPitch()
    }

    public var isDefault: Bool {
        self.isDefaultTonicPitch && self.isDefaultPitchDirection
    }
    
    public var isDefaultTonicPitch: Bool {
        self.tonicPitch.midi == Pitch.defaultTonicMIDI
    }
    
    public var isDefaultPitchDirection: Bool {
        self.pitchDirection == PitchDirection.default
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = pitch(for: Pitch.defaultTonicMIDI) // Reset to default pitch
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }

    // Check if it's safe to shift the tonic pitch up by an octave
    public func canShiftUpOneOctave() -> Bool {
        return MIDIHelper.isValidMIDI(note: Int(tonicPitch.midi) + 12)
    }

    // Check if it's safe to shift the tonic pitch down by an octave
    public func canShiftDownOneOctave() -> Bool {
        return MIDIHelper.isValidMIDI(note: Int(tonicPitch.midi) - 12)
    }

    // Perform the shift up by one octave if safe
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave() {
            tonicPitch = pitch(for: tonicPitch.midi + 12)
        }
    }

    // Perform the shift down by one octave if safe
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave() {
            tonicPitch = pitch(for: tonicPitch.midi - 12)
        }
    }
    
    public var tonicRegisterNotes: ClosedRange<Int> {
        let tonicNote = Int(tonicMIDI)
        return pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    // Computed property to determine the octave shift
    public var octaveShift: Int {        
        let midi = if pitchDirection == .upward || !MIDIHelper.isValidMIDI(note: Int(self.tonicMIDI) - 12) {
            self.tonicMIDI
        } else {
            self.tonicMIDI - 12
        }
        return pitch(for: midi).octave - 4
    }
    
    public var naturalsBelowTritone: [Int8] {
        return Pitch.naturalMIDI.filter({$0 < tritoneMIDI})
    }

    public var naturalsAboveTritone: [Int8] {
        return Pitch.naturalMIDI.filter({$0 > tritoneMIDI})
    }
    
    public var tonicMIDI: Int8 {
        tonicPitch.midi
    }
    
    public var tritoneMIDI: Int8 {
        let offset: Int8 = (pitchDirection == .upward || pitchDirection == .both) ? 6 : -6
        let primaryTritone = tonicMIDI + offset
        
        // If the primary tritone is valid, return it, otherwise return the opposite
        return MIDIHelper.isValidMIDI(note: Int(primaryTritone)) ? primaryTritone : tonicMIDI - offset
    }
    
}

// TODO: put MIDI capability here

//midiConductor?.sendTonic(noteNumber: UInt7(tonicPitch.midi), midiChannel: midiChannel(layoutChoice: layoutChoice, stringsLayoutChoice: stringsLayoutChoice))
