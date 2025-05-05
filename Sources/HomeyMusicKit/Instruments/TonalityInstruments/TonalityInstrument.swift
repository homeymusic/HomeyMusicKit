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
        return tonality.pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modeInts: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: tonality.mode)
        return rotatedModes + [rotatedModes.first!]
    }

}
