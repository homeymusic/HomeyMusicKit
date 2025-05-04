import SwiftData
import MIDIKitCore

@Model
public final class TonalityInstrument: Instrument {
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    @Relationship
    public var tonality: Tonality
    
    public var showModePicker: Bool = false
    public var showTonicPicker: Bool = false

    public var areModeAndTonicLinked: Bool = true
    public var isAutoModeAndTonicEnabled: Bool = false

    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    
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
        let tonicNote = Int(tonality.tonicPitch.midiNote.number)
        return tonality.pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modeInts: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: tonality.mode)
        return rotatedModes + [rotatedModes.first!]
    }

}
