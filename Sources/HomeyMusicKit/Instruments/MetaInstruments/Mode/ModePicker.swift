import SwiftData

@Model
public final class ModePicker: KeyboardInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.modePicker
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var latching: Bool                    = false
    public var showOutlines: Bool                = true

    // — persisted KeyboardInstrument state
    public var rows: Int = ModePicker.defaultRows
    public var cols: Int = ModePicker.defaultCols

    public init() {}

    // — config constants (in-memory only)
    public static let defaultRows = 0, minRows = 0, maxRows = 0
    public static let defaultCols = 6, minCols = 6, maxCols = 6

    // — override the protocol’s static “factory defaults”
    public static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { [.mode] }
    public static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { [] }

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    // — now as Sets
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = ModePicker.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = ModePicker.defaultIntervalLabelChoices

    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }

    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }
}
