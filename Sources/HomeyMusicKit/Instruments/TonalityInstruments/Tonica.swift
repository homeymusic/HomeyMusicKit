import SwiftData
import MIDIKitCore

@Model
public final class Tonica: Instrument {
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    @Relationship
    public var tonality: Tonality
    
    public var areModeAndTonicLinked: Bool = true
    public var isAutoModeAndTonicEnabled: Bool = false

    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    
    public var pitchLabelTypes: Set<PitchLabelType> = Tonica.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Tonica.defaultIntervalLabelTypes
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?
    
    public static var defaultPitchLabelTypes:    Set<PitchLabelType>    { [ .letter ] }
    public static var defaultIntervalLabelTypes: Set<IntervalLabelType> { [ .symbol ] }
    
    @Transient
    public var midiConductor: MIDIConductor?
    public var allMIDIInChannels: Bool = true
    public var allMIDIOutChannels: Bool = true

    
    public var midiNoteInts: ClosedRange<Int> {
        let tonicNote = Int(tonality.tonicPitch.midiNote.number)
        return tonality.pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
}
