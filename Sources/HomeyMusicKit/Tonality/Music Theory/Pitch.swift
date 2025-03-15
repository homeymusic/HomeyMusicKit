import SwiftUI
import MIDIKitCore
import Combine

/// Represents a musical pitch based on a MIDI note.
public final class Pitch: ObservableObject, Identifiable, Hashable, Comparable {
    // MARK: - Factory
    
    /// Creates an array of all available pitches (if needed).
    /// Checks whether a given MIDI note number is valid.
    public static func isValid(_ integerValue: Int) -> Bool {
        return (0...127).contains(integerValue)
    }
    
    // Default tonic MIDI note.
    public static let defaultTonicMIDINoteNumber: MIDINoteNumber = 60

    public static func isNatural(_ noteNumber: Int) -> Bool {
        let pitchClass = MIDINote(MIDINoteNumber(modulo(noteNumber, 12)))
        return !pitchClass.isSharp
    }
        
    public static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.midiNote.number == rhs.midiNote.number
    }
    
    public static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        return lhs.midiNote.number < rhs.midiNote.number
    }
    
    // MARK: - Instance Properties
    
    /// The underlying MIDI note.
    public let midiNote: MIDINote
    public let pitchClass: PitchClass
    
    /// Indicates whether the pitch is activated.
    @Published public var isActivated: Bool = false
    
    private var onActivateCallbacks: [(Pitch) -> Void] = []
    private var onDeactivateCallbacks: [(Pitch) -> Void] = []
    
    /// Register a callback for when this pitch is activated.
    public func addOnActivateCallback(_ callback: @escaping (Pitch) -> Void) {
        onActivateCallbacks.append(callback)
    }
    
    /// Register a callback for when this pitch is deactivated.
    public func addOnDeactivateCallback(_ callback: @escaping (Pitch) -> Void) {
        onDeactivateCallbacks.append(callback)
    }
    
    /// Call this method when the pitch becomes activated.
    public func activate() {
        guard !isActivated else { return }
        for callback in onActivateCallbacks {
            callback(self)
        }
        isActivated = true
        pitchClass.incrementActivatedPitches()
    }
    
    /// Call this method when the pitch becomes deactivated.
    public func deactivate() {
        guard isActivated else { return }
        for callback in onDeactivateCallbacks {
            callback(self)
        }
        isActivated = false
        pitchClass.decrementActivatedPitches()
    }
    
    // MARK: - Initialization
    
    public init(midiNote: MIDINote, pitchClass: PitchClass) {
        self.midiNote = midiNote
        self.pitchClass = pitchClass
    }
    
    // MARK: - Computed Properties
    
    /// The fundamental frequency of the pitch.
    public var fundamentalFrequency: Double {
        return midiNote.frequencyValue()
    }
    
    /// The period corresponding to the fundamental frequency.
    public var fundamentalPeriod: Double {
        return 1.0 / fundamentalFrequency
    }
    
    /// The wavelength of the pitch. (Speed of sound is computed using a MIDI note of 65.)
    public var wavelength: Double {
        let speedOfSound = MIDINote.calculateFrequency(midiNote: 65)
        return speedOfSound * fundamentalPeriod
    }
    
    /// The wavenumber (inverse of wavelength).
    public var wavenumber: Double {
        return 1.0 / wavelength
    }
    
    /// Computes a cochlear position using a Greenwood-like function.
    public var cochlea: Double {
        return 100 - 100 * (log10(fundamentalFrequency / 165.4 + 0.88) / 2.1)
    }
    
    /// Returns true if the note is natural (i.e. not sharp).
    public var isNatural: Bool {
        return !midiNote.isSharp
    }
    
    public func isOctave(relativeTo otherPitch: Pitch) -> Bool {
        let semitoneDifference = Int(self.midiNote.number) - Int(otherPitch.midiNote.number)
        return abs(semitoneDifference) == 12
    }
            
    /// The octave of the pitch.
    public var octave: Int {
        return Int(midiNote.number) / 12 - 1
    }
    
    /// The integer value of the MIDI note.
    public var intValue: Int {
        return Int(midiNote.number)
    }
    
    // MARK: - Behavior
    
    /// Computes the distance (in semitones) from another pitch.
    public func distance(from other: Pitch) -> Int {
        return Int(midiNote.number) - Int(other.midiNote.number)
    }
    
    // MARK: - Musical Notation Helpers
    
    // MARK: - Equatable, Hashable, Comparable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(midiNote.number)
    }
    
}
