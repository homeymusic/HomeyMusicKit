import SwiftUI
import MIDIKitCore
import Combine

/// Represents a musical pitch based on a MIDI note.
public final class Pitch: ObservableObject, Identifiable, Hashable, Comparable {
    // MARK: - Factory
    
    /// Creates an array of all available pitches (if needed).
    public static func allPitches() -> [Pitch] {
        MIDINote.allNotes().map { Pitch(midiNote: $0) }
    }
    
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
    }
    
    /// Call this method when the pitch becomes deactivated.
    public func deactivate() {
        guard isActivated else { return }
        for callback in onDeactivateCallbacks {
            callback(self)
        }
        isActivated = false
    }
    
    // MARK: - Initialization
    
    /// Initializes a new Pitch with the given MIDI note.
    private init(midiNote: MIDINote) {
        self.midiNote = midiNote
    }
    
    // MARK: - Computed Properties
    
    /// The pitch class computed from the MIDI note number.
    public var pitchClass: PitchClass {
        return PitchClass(noteNumber: Int(midiNote.number))
    }
    
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
    
    /// Returns the letter representation (e.g. "C", "C♯", "D♭", etc.) using the provided accidental.
    public func letter(using accidental: Accidental) -> String {
        switch pitchClass {
        case .zero:
            return "C"
        case .one:
            return accidental == .sharp ? "C♯" : "D♭"
        case .two:
            return "D"
        case .three:
            return accidental == .sharp ? "D♯" : "E♭"
        case .four:
            return "E"
        case .five:
            return "F"
        case .six:
            return accidental == .sharp ? "F♯" : "G♭"
        case .seven:
            return "G"
        case .eight:
            return accidental == .sharp ? "G♯" : "A♭"
        case .nine:
            return "A"
        case .ten:
            return accidental == .sharp ? "A♯" : "B♭"
        case .eleven:
            return "B"
        }
    }
    
    /// Returns the fixed-do notation (e.g. "Do", "Re♯", etc.) using the provided accidental.
    public func fixedDo(using accidental: Accidental) -> String {
        switch pitchClass {
        case .zero:
            return "Do"
        case .one:
            return accidental == .sharp ? "Do♯" : "Re♭"
        case .two:
            return "Re"
        case .three:
            return accidental == .sharp ? "Re♯" : "Mi♭"
        case .four:
            return "Mi"
        case .five:
            return "Fa"
        case .six:
            return accidental == .sharp ? "Fa♯" : "Sol♭"
        case .seven:
            return "Sol"
        case .eight:
            return accidental == .sharp ? "Sol♯" : "La♭"
        case .nine:
            return "La"
        case .ten:
            return accidental == .sharp ? "La♯" : "Si♭"
        case .eleven:
            return "Si"
        }
    }
    
    // MARK: - Equatable, Hashable, Comparable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(midiNote.number)
    }
    
}
