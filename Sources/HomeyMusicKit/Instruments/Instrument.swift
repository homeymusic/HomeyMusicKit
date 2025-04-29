import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
    var tonality:         Tonality     { get set }
    var synthConductor:   SynthConductor? { get set }
    var midiConductor:    MIDIConductor?     { get set }
    
    var pitches: [Pitch] { get set }
    func pitch(for midi: MIDINoteNumber) -> Pitch
    
    func activate(midiNoteNumber: MIDINoteNumber)
    func deactivate(midiNoteNumber: MIDINoteNumber)
    func toggle(midiNoteNumber: MIDINoteNumber)
    
    var tonicPitch: Pitch { get set }
    var pitchDirection: PitchDirection { get set }
    var mode: Mode { get set }
    
    var midiChannelRawValue: UInt4 { get set }
    var midiChannel: MIDIChannel { get set }
    
    var latching: Bool { get set }
    
    var showOutlines: Bool { get set }
    
    var accidental: Accidental   { get set }
    var accidentalRawValue: Int  { get set }
    
    var pitchLabelChoices:    Set<PitchLabelChoice>    { get set }
    var intervalLabelChoices: Set<IntervalLabelChoice> { get set }
    
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { get }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { get }
    
    var areDefaultLabelChoices: Bool { get }
    func resetDefaultLabelChoices()
    
    var intervalColorPalette: IntervalColorPalette? { get set }
    var pitchColorPalette:    PitchColorPalette?    { get set }
    
    var allIntervals: [IntervalNumber: Interval] { get }
    
    func interval(fromTonicTo pitch: Pitch) -> Interval
    
    @MainActor
    var colorPalette: ColorPalette { get set }
}

public extension Instrument {
    
    func pitch(for midiNoteNumber: MIDINoteNumber) -> Pitch {
        pitches[Int(midiNoteNumber)]
    }
    
    var activatedPitches: [Pitch] {
        pitches.filter{ $0.isActivated }
    }
    
    func deactivateAllPitches() {
        pitches.forEach { $0.deactivate() }
    }
    
    func activate(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        guard !pitch.isActivated else { return }
        pitch.activate()
        synthConductor?.noteOn(pitch: pitch)
        midiConductor?.noteOn(pitch: pitch, channel: midiChannel)
    }
    
    func deactivate(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        guard pitch.isActivated else { return }
        pitch.deactivate()
        synthConductor?.noteOff(pitch: pitch)
        midiConductor?.noteOff(pitch: pitch, channel: midiChannel)
    }
    
    func toggle(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        if pitch.isActivated {
            deactivate(midiNoteNumber: midiNoteNumber)
        } else {
            activate(midiNoteNumber: midiNoteNumber)
        }
    }
    
    var tonicPitch: Pitch {
        get {
            pitches[Int(tonality.tonicPitch)]
        }
        set {
            tonality.tonicPitch = newValue.midiNote.number
        }
    }
    
    var pitchDirection: PitchDirection {
      get { tonality.pitchDirection }
      set { tonality.pitchDirection = newValue }
    }
    
    var mode: Mode {
      get { tonality.mode }
      set { tonality.mode = newValue }
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
    
    var allIntervals: [IntervalNumber: Interval] {
        Interval.allIntervals()
    }
    
    func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return allIntervals[distance]!
    }
    
    @MainActor
    var colorPalette: ColorPalette {
        get {
            if let interval = intervalColorPalette {
                return interval
            }
            if let pitch = pitchColorPalette {
                return pitch
            }
            return IntervalColorPalette.homey
        }
        set {
            // If it's an IntervalColorPalette, store it there and clear the pitch palette
            if let interval = newValue as? IntervalColorPalette {
                intervalColorPalette = interval
                pitchColorPalette    = nil
            }
            // Otherwise if it's a PitchColorPalette, store it there and clear the interval palette
            else if let pitch = newValue as? PitchColorPalette {
                pitchColorPalette    = pitch
                intervalColorPalette = nil
            }
            // Fallback: reset to default homey interval palette
            else {
                intervalColorPalette = IntervalColorPalette.homey
                pitchColorPalette    = nil
            }
        }
    }
    
    var octaveShift: Int {
        let defaultOctave = 4
        return tonicPitch.octave + (pitchDirection == .downward ? -1 : 0) - defaultOctave
    }
    
    var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) + 12)
    }
    
    var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) - 12)
    }
    
    func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number + 12)
            buzz()
        }
    }
    
    func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
            buzz()
        }
    }

    func resetTonality() {
        tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber)
        mode = .default
        pitchDirection = .default
        buzz()
    }

    var isDefaultTonality: Bool {
        isDefaultTonicPitch && isDefaultPitchDirection && isDefaultMode
    }
    
    var isDefaultTonicPitch: Bool {
        tonicPitch.midiNote.number == Pitch.defaultTonicMIDINoteNumber
    }
    
    var isDefaultMode: Bool {
        mode == Mode.default
    }
    
    var isDefaultPitchDirection: Bool {
        pitchDirection == PitchDirection.default
    }
    

}
