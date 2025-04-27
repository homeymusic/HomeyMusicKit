import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Linear: KeyboardInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.linear
    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted KeyboardInstrument state
    public var rows: Int = Linear.defaultRows
    public var cols: Int = Linear.defaultCols

    // — config constants (in-memory only)
    public static let defaultRows = 0, minRows = 0, maxRows = 5
    public static let defaultCols = 9, minCols = 6, maxCols = 18

    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }

    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Linear.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Linear.defaultIntervalLabelChoices

    /// Designated init — call `Linear()` or supply custom rows/cols
    public init() {}
}
