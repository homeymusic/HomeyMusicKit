
import SwiftUI
import MIDIKitCore

@Observable
public final class Pitch: Identifiable, Hashable, Comparable {
    // MARK: - Instance Properties
    
    /// The underlying MIDI note.
    public let midiNote: MIDINote
        
    public var isActivated: Bool = false {
        didSet {
            onActivationChanged?(self, isActivated)
        }
    }
    public var onActivationChanged: ((Pitch, Bool) -> Void)?

    // MARK: - Initialization
    
    /// Initializes a new Pitch with the given MIDI note.
    private init(midiNote: MIDINote) {
        self.midiNote = midiNote
    }
    
    // MARK: - Activation
    
    /// Call this method when the pitch becomes activated.
    public func activate() {
        guard !isActivated else { return }
        isActivated = true
    }
    
    /// Call this method when the pitch becomes deactivated.
    public func deactivate() {
        guard isActivated else { return }
        isActivated = false
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
    
    // MARK: - Equatable, Hashable, Comparable
    
    public func interval(for instrument: Instrument) -> Interval {
        return instrument.interval(fromTonicTo: self)
    }
    
    public func consonanceDissonance(for instrument: Instrument) -> ConsonanceDissonance {
        interval(for: instrument).consonanceDissonance(for: instrument)
    }
    
    public func majorMinor(for instrument: Instrument) -> MajorMinor {
        interval(for: instrument).majorMinor
    }

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
    
    nonisolated public static func isNatural(_ noteNumber: Int) -> Bool {
        let pitchClass = MIDINote(MIDINoteNumber(modulo(noteNumber, 12)))
        return !pitchClass.isSharp
    }
    
    // MARK: - Conformance
    
    /// Required by `Identifiable`: you can use `intValue` or the `MIDINote.number` itself.
    public var id: UInt7 {
        midiNote.number
    }
    
    public static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        lhs.midiNote == rhs.midiNote
    }
    
    public static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        lhs.midiNote < rhs.midiNote
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(midiNote.number)
    }
    
}
