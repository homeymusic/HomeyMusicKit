import SwiftUI

@MainActor
public class TonalContext: ObservableObject {
    // Singleton instance
    public static let shared = TonalContext()

    // Properties to drive UI changes
    public let allPitches: [Pitch] = Array(0...127).map { Pitch($0) }
    
    @Published public var tonicPitch: Pitch
    @Published public var pitchDirection: PitchDirection
    @Published public var accidental: Accidental

    // State Manager to handle saving/loading
    private let stateManager = TonalContextStateManager()

    // Private initializer for singleton pattern
    private init() {
        // Load the initial state from the state manager
        let savedState = stateManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection
        self.accidental = savedState.accidental
        
        // Bind and save state changes
        stateManager.bindAndSave(tonalContext: self)
    }

    public func resetToDefaults() {
        // Set the defaults for tonicPitch, pitchDirection, and accidental
        self.tonicPitch = allPitches[Int(Pitch.defaultMIDI)] // Reset to default pitch
        self.pitchDirection = .default // Reset to default pitch direction
        self.accidental = .default // Reset to default accidental
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
            tonicPitch = pitch(for: tonicPitch.midi + 12)!
        }
    }

    // Perform the shift down by one octave if safe
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave() {
            tonicPitch = pitch(for: tonicPitch.midi - 12)!
        }
    }
    
    // Helper function to get a single Pitch from a MIDI value
    public func pitch(for midi: Int8) -> Pitch? {
        guard safeMIDI(midi: Int(midi)) else { return nil }
        return allPitches[Int(midi)]
    }

    // Helper function to get an array of Pitches for a range of MIDI values
    public func pitches(for midiRange: ClosedRange<Int8>) -> [Pitch] {
        let validRange = midiRange.clamped(to: 0...127)
        return validRange.map { allPitches[Int($0)] }
    }

    public func midiRange() -> ClosedRange<Int> {
        let midi = Int(tonicPitch.midi)
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
}

// TODO: put MIDI capability here

//midiConductor?.sendTonic(noteNumber: UInt7(tonicPitch.midi), midiChannel: midiChannel(layoutChoice: layoutChoice, stringsLayoutChoice: stringsLayoutChoice))
