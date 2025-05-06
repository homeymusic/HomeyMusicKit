import SwiftData
import MIDIKitCore

@Model
public final class TonalityInstrument: Instrument {
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    public init(
        tonality: Tonality = Tonality(),
        showModePicker: Bool = true,
        showTonicPicker: Bool = true,
        areModeAndTonicLinked: Bool = true,
        isAutoModeAndTonicEnabled: Bool = true,
        showOutlines: Bool = true,
        showTonicOctaveOutlines: Bool = true,
        showModeOutlines: Bool = true
    ) {
        self.tonality                  = tonality
        self.showModePicker            = showModePicker
        self.showTonicPicker           = showTonicPicker
        self.areModeAndTonicLinked     = areModeAndTonicLinked
        self.isAutoModeAndTonicEnabled = isAutoModeAndTonicEnabled
        self.showOutlines              = showOutlines
        self.showTonicOctaveOutlines   = showTonicOctaveOutlines
        self.showModeOutlines          = showModeOutlines
    }
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Transient
    public var intervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public var tonicPitch: Pitch {
        get {
            _tonicPitch
        }
        set {
            let tonicMIDINoteNumber: MIDINoteNumber = newValue.midiNote.number
            tonality.tonicMIDINoteNumber = tonicMIDINoteNumber
            tonality.broadcastChange(tonicMIDINoteNumber) { midiConductor, updatedMIDINoteNumber, midiChannel in
                midiConductor.tonicMIDINoteNumber(updatedMIDINoteNumber, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var pitchDirection: PitchDirection {
        get {
            _pitchDirection
        }
        set {
            tonality.pitchDirectionRaw = newValue.rawValue
            tonality.broadcastChange(newValue.rawValue) { midiConductor, updatedPitchDirectionRaw, midiChannel in
                midiConductor.pitchDirectionRaw(updatedPitchDirectionRaw, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var mode: Mode {
        get {
            _mode
        }
        set {
            tonality.modeRaw = newValue.rawValue
            tonality.broadcastChange(newValue.rawValue) { midiConductor, updatedModeRaw, midiChannel in
                midiConductor.modeRaw(updatedModeRaw, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var showModePicker: Bool = true
    public var showTonicPicker: Bool = true
    
    public var areModeAndTonicLinked: Bool = true
    public var isAutoModeAndTonicEnabled: Bool = true
    
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = true
    
    public var pitchLabelTypes: Set<PitchLabelType> = TonalityInstrument.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = TonalityInstrument.defaultIntervalLabelTypes
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?
    
    public static var defaultPitchLabelTypes:    Set<PitchLabelType>    { [ .letter, .mode ] }
    public static var defaultIntervalLabelTypes: Set<IntervalLabelType> { [ .symbol ] }
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    @Transient
    public var midiConductor: MIDIConductor?
    public var allMIDIInChannels: Bool = true
    public var allMIDIOutChannels: Bool = true
    
    public var midiNoteInts: ClosedRange<Int> {
        let tonicNote = Int(tonicPitch.midiNote.number)
        return tonality.pitchDirectionRaw == PitchDirection.downward.rawValue ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modeInts: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: mode)
        return rotatedModes + [rotatedModes.first!]
    }
    
    
    public var octaveShift: Int {
        let defaultOctave = 4
        return (Int(tonality.tonicMIDINoteNumber) / 12 - 1) + (tonality.pitchDirectionRaw == PitchDirection.downward.rawValue ? -1 : 0) - defaultOctave
    }
    
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonality.tonicMIDINoteNumber) + 12)
    }
    
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonality.tonicMIDINoteNumber) - 12)
    }
    
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonality.tonicMIDINoteNumber = tonality.tonicMIDINoteNumber + 12
        }
    }
    
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonality.tonicMIDINoteNumber = tonality.tonicMIDINoteNumber - 12
        }
    }
    
    public func resetTonality() {
        tonality.tonicMIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
        tonality.modeRaw = Mode.default.rawValue
        tonality.pitchDirectionRaw = PitchDirection.default.rawValue
    }
    
    public var isDefaultTonality: Bool {
        isDefaultTonicMIDINoteNumber && isDefaultPitchDirection && isDefaultMode
    }
    
    public var isDefaultTonicMIDINoteNumber: Bool {
        tonality.tonicMIDINoteNumber == Pitch.defaultTonicMIDINoteNumber
    }
    
    public var isDefaultMode: Bool {
        tonality.modeRaw == Mode.default.rawValue
    }
    
    public var isDefaultPitchDirection: Bool {
        tonality.pitchDirectionRaw == PitchDirection.default.rawValue
    }
    
    
}
