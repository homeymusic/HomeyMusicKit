import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
    var pitches: [Pitch] { get set }
    func pitch(for midi: MIDINoteNumber) -> Pitch
    
    var tonicPitch: Pitch { get set }
    var tonicPitchMIDINoteNumber: MIDINoteNumber { get set }
    
    var pitchDirectionRawValue: Int { get set }
    var pitchDirection: PitchDirection { get set }
    
    var mode: Mode               { get set }
    var modeRawValue: Int        { get set }
    
    var accidental: Accidental   { get set }
    var accidentalRawValue: Int  { get set }
    
    var midiChannelRawValue: UInt4 { get set }
    var midiChannel: MIDIChannel { get set }
    
    var latching: Bool { get set }
    
    var showOutlines: Bool { get set }
    
    /// Now sets instead of arrays
    var pitchLabelChoices:    Set<PitchLabelChoice>    { get set }
    var intervalLabelChoices: Set<IntervalLabelChoice> { get set }
    
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { get }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { get }
    
    var areDefaultLabelChoices: Bool { get }
    func resetDefaultLabelChoices()
    
    var intervalColorPalette: IntervalColorPalette? { get set }
    var pitchColorPalette:    PitchColorPalette?    { get set }
    
    @MainActor
    var colorPalette: ColorPalette { get }
}

public extension Instrument {
    
    func pitch(for midiNoteNumber: MIDINoteNumber) -> Pitch {
        pitches[Int(midiNoteNumber)]
    }
    
    var tonicPitch: Pitch {
        get {
            Pitch.allPitches()[Int(tonicPitchMIDINoteNumber)]
        }
        set {
            tonicPitchMIDINoteNumber = newValue.midiNote.number
        }
    }
    var pitchDirection: PitchDirection {
        get {
            return PitchDirection(rawValue: pitchDirectionRawValue)
            ?? PitchDirection.default
        }
        set {
            pitchDirectionRawValue = newValue.rawValue
        }
    }
    var mode: Mode {
        get {
            Mode(rawValue: modeRawValue) ?? .default
        }
        set {
            modeRawValue = newValue.rawValue
        }
    }
    var accidental: Accidental {
        get {
            Accidental(rawValue: accidentalRawValue) ?? .default
        }
        set {
            accidentalRawValue = newValue.rawValue
        }
    }
    var midiChannel: MIDIChannel {
        get {
            MIDIChannel(rawValue: midiChannelRawValue) ?? .default
        }
        set {
            midiChannelRawValue = newValue.rawValue
        }
    }
    
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { [ .octave ] }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { [ .symbol ] }
    
    var areDefaultLabelChoices: Bool {
        pitchLabelChoices    == Self.defaultPitchLabelChoices &&
        intervalLabelChoices == Self.defaultIntervalLabelChoices
    }
    
    func resetDefaultLabelChoices() {
        pitchLabelChoices    = Self.defaultPitchLabelChoices
        intervalLabelChoices = Self.defaultIntervalLabelChoices
    }
    
    @MainActor
    var colorPalette: ColorPalette {
        if let interval = intervalColorPalette {
            return interval
        }
        if let pitch = pitchColorPalette {
            return pitch
        }
        return IntervalColorPalette.homey
    }
}
