import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    init(tonality: Tonality, pitches: [Pitch])
    
    var instrumentChoice: InstrumentChoice { get }
    
    var tonality:         Tonality     { get set }
    var synthConductor:   SynthConductor? { get set }
    var midiConductor:    MIDIConductor?     { get set }
    
    var pitches: [Pitch] { get set }
    func pitch(for midi: MIDINoteNumber) -> Pitch
    var activatedPitches: [Pitch] { get }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber])
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func deactivateAllMIDINoteNumbers()
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    
    var tonicPitch: Pitch { get set }
    var pitchDirection: PitchDirection { get set }
    var mode: Mode { get set }
    
    var midiInChannelRawValue: UInt4 { get set }
    var midiInChannel: MIDIChannel { get set }
    var allMIDIInChannels: Bool { get set }
    
    var midiOutChannelRawValue: UInt4 { get set }
    var midiOutChannel: MIDIChannel { get set }
    var allMIDIOutChannels: Bool { get set }
    
    var latching: Bool { get set }
    
    var showOutlines: Bool { get set }
    var showTonicOctaveOutlines: Bool { get set }
    var showModeOutlines: Bool { get set }
    
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
    
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber]) {
        deactivateAllMIDINoteNumbers()
        for midiNoteNumber in midiNoteNumbers {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        }
    }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        synthConductor?.noteOn(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOn(pitch: pitch, midiOutChannel: ch)
        }
        pitch.activate()
    }
    
    func deactivateAllMIDINoteNumbers() {
        MIDINote.allNotes().forEach { midiNote in
            deactivateMIDINoteNumber(midiNoteNumber: midiNote.number)
        }
    }
    
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        synthConductor?.noteOff(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOff(pitch: pitch, midiOutChannel: ch)
        }
        pitch.deactivate()
    }
    
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
        if pitch.isActivated {
            deactivateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        } else {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        }
    }
    
    var pitchDirection: PitchDirection {
        get { tonality.pitchDirection }
        set {
            tonality.pitchDirection = newValue
            midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
                midiConductor?.pitchDirection(newValue, midiOutChannel: ch)
            }
        }
    }
    
    var mode: Mode {
        get { tonality.mode }
        set {
            tonality.mode = newValue
            midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
                midiConductor?.mode(newValue, midiOutChannel: ch)
            }
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
    
    var midiInChannel: MIDIChannel {
        get {
            MIDIChannel(rawValue: midiInChannelRawValue) ?? .default
        }
        set {
            midiInChannelRawValue = newValue.rawValue
        }
    }
    
    var midiOutChannel: MIDIChannel {
        get {
            MIDIChannel(rawValue: midiOutChannelRawValue) ?? .default
        }
        set {
            midiOutChannelRawValue = newValue.rawValue
        }
    }
    
    private func sendToOutChannels(_ block: (MIDIChannel) -> Void) {
        if allMIDIOutChannels {
            for channel in MIDIChannel.allCases {
                block(channel)
            }
        } else {
            block(midiOutChannel)
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
        }
    }
    
    func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
        }
    }
    
    func resetTonality() {
        tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber)
        mode = .default
        pitchDirection = .default
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
