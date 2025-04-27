import SwiftData
import MIDIKitCore

@Model
public final class Linear: KeyboardInstrument {
    public static let rowConfig = (default: 0, min: 0, max: 5)
    public static let colConfig = (default: 9, min: 6, max: 18)

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.linear
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.linear.midiChannel.rawValue

    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue
    public var modeRawValue: Int       = Mode.default.rawValue
    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool      = false
    public var showOutlines: Bool  = true

    public var rows: Int = Linear.rowConfig.default
    public var cols: Int = Linear.colConfig.default

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Linear.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Linear.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    public init() {}
}
