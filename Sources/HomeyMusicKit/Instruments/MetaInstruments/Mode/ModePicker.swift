import SwiftData
import MIDIKitCore

@Model
public final class ModePicker: KeyboardInstrument {
    public static let rowConfig = (default: 0, min: 0, max: 0)
    public static let colConfig = (default: 6, min: 6, max: 6)

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.modePicker
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()

    @Relationship
    public var tonality: Tonality

    @Transient
    public var synthConductor: SynthConductor?

    @Transient
    public var midiConductor: MIDIConductor?

    public var midiChannelRawValue: MIDIChannelNumber = MIDIChannel.channel1.rawValue

    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool = false
    public var showOutlines: Bool = true

    public var rows: Int = ModePicker.rowConfig.default
    public var cols: Int = ModePicker.colConfig.default

    public var pitchLabelChoices: Set<PitchLabelChoice> = ModePicker.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = ModePicker.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?

    public init(tonality: Tonality = Tonality()) {
        self.tonality = tonality
    }
}

