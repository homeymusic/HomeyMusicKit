import SwiftData
import MIDIKitCore

@Model
public final class Linear: KeyboardInstrument {
    public static let rowConfig = (default: 0, min: 0, max: 5)
    public static let colConfig = (default: 9, min: 6, max: 18)

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.linear
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?

    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.linear.midiChannel.rawValue

    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool      = false
    public var showOutlines: Bool  = true

    public var rows: Int = Linear.rowConfig.default
    public var cols: Int = Linear.colConfig.default

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Linear.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Linear.defaultIntervalLabelChoices

    @Relationship
    public var intervalColorPalette: IntervalColorPalette?
    
    @Relationship
    public var pitchColorPalette:    PitchColorPalette?

    public init(tonality: Tonality = Tonality()) {
        self.tonality = tonality
    }
}
