import SwiftUI

@MainActor
public class TonalContext: ObservableObject {
    // Singleton instance
    public static let shared = TonalContext()

    // Properties to drive UI changes
    public let allPitches: [Pitch] = Array(0...127).map { Pitch($0) }
    
    @Published public var tonicPitch: Pitch
    @Published public var pitchDirection: PitchDirection

    // State Manager to handle saving/loading
    private let stateManager = TonalContextStateManager()

    // Private initializer for singleton pattern
    private init() {
        // Load the initial state from the state manager
        let savedState = stateManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection
        
        // Bind and save state changes
        stateManager.bindAndSave(tonalContext: self)
    }

    public func resetToDefaults() {
        resetTonicPitch()
        resetPitchDirection()
    }
    
    public var isDefaultTonicPitch: Bool {
        self.tonicPitch.midi == Pitch.defaultTonicMIDI
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = pitch(for: Pitch.defaultTonicMIDI) // Reset to default pitch
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }

    // Check if it's safe to shift the tonic pitch up by an octave
    public func canShiftUpOneOctave() -> Bool {
        return safeMIDI(midi: Int(tonicPitch.midi) + 12)
    }

    // Check if it's safe to shift the tonic pitch down by an octave
    public func canShiftDownOneOctave() -> Bool {
        return safeMIDI(midi: Int(tonicPitch.midi) - 12)
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
    
    public func pitch(for midi: Int8) -> Pitch {
        guard safeMIDI(midi: Int(midi)) else {
            fatalError("Invalid MIDI value: \(midi). It must be between 0 and 127.")
        }
        return allPitches[Int(midi)]
    }
    
    // Helper function to get an array of Pitches for a range of MIDI values, failing fast on invalid input
    public func pitches(for midiRange: ClosedRange<Int8>) -> [Pitch] {
        guard midiRange.lowerBound >= 0 && midiRange.upperBound <= 127 else {
            fatalError("Invalid MIDI range: \(midiRange). MIDI values must be between 0 and 127.")
        }
        return midiRange.map { allPitches[Int($0)] }
    }
    
    public var midiRange: ClosedRange<Int> {
        let midi = Int(tonicMIDI)
        return pitchDirection == .downward ? midi - 12 ... midi : midi ... midi + 12
    }
    
    // Computed property to determine the octave shift
    public var octaveShift: Int {
        return tonicPitch.octave - 4
    }
    
    // Safe MIDI checker function
    public func safeMIDI(midi: Int) -> Bool {
        return midi >= 0 && midi <= 127
    }
    
    public var naturalsBelowTritone: [Int8] {
        let tritoneMIDI = Int(tonicMIDI) + 6
        if safeMIDI(midi: tritoneMIDI) {
            return Pitch.naturalMIDI.filter({$0 < tritoneMIDI})
        } else {
            return Pitch.naturalMIDI
        }
    }

    public var naturalsAboveTritone: [Int8] {
        let tritoneMIDI = Int(tonicMIDI) + 6
        if safeMIDI(midi: tritoneMIDI) {
            return Pitch.naturalMIDI.filter({$0 > tritoneMIDI})
        } else {
            return []
        }
    }
    
    public var tonicMIDI: Int8 {
        tonicPitch.midi
    }
}

// TODO: put MIDI capability here

//midiConductor?.sendTonic(noteNumber: UInt7(tonicPitch.midi), midiChannel: midiChannel(layoutChoice: layoutChoice, stringsLayoutChoice: stringsLayoutChoice))
