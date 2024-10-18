import MIDIKitCore
import SwiftUI

@MainActor
public class TonalContext: ObservableObject, @unchecked Sendable  {
    // Singleton instance
    public static let shared = TonalContext()
    
    // State Manager to handle saving/loading
    private let defaultsManager = TonalContextDefaultsManager()
    
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
    
    // Function to check if shifting up one octave is valid
    public var canShiftUpOneOctave: Bool {
        return MIDIConductor.isValidMIDI(Int(tonicMIDI) + 12)
    }

    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return MIDIConductor.isValidMIDI(Int(tonicMIDI) - 12)
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
    
    // Private initializer for singleton pattern
    private init() {
        // Load the initial state from the state manager
        let savedState = defaultsManager.loadState(allPitches: Pitch.allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection
        
        // Bind and save state changes
        defaultsManager.bindAndSave(tonalContext: self)
    }
    
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
    
    // Computed property to determine the octave shift
    public var octaveShift: Int {
        let midi = if pitchDirection == .upward || !canShiftDownOneOctave {
            self.tonicMIDI
        } else {
            self.tonicMIDI - 12
        }
        return Pitch.pitch(for: midi).octave - 4
    }
    
    public var naturalsBelowTritone: [MIDINoteNumber] {
        return Pitch.naturalMIDI.filter({$0 < tritoneMIDI})
    }
    
    public var naturalsAboveTritone: [MIDINoteNumber] {
        return Pitch.naturalMIDI.filter({$0 > tritoneMIDI})
    }
    
    public var tonicMIDI: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
    public var tritoneMIDI: MIDINoteNumber {
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
