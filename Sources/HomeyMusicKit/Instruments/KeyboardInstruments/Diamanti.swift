import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Diamanti: KeyboardInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.diamanti
    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted KeyboardInstrument state
    public var rows: Int = Diamanti.defaultRows
    public var cols: Int = Diamanti.defaultCols

    // — config constants (in-memory only)
    public static let defaultRows = 0, minRows = 0, maxRows = 2
    public static let defaultCols = 13, minCols = 6, maxCols = 18

    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }

    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Diamanti.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Diamanti.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    // — designated initializer: you can call `Diamanti()` or supply custom rows/cols
    public init() {}

    // — subclass‐specific column stepping
    public func fewerCols() {
        guard fewerColsAreAvailable else { return }
        let colJump: [Int: Int] = [
            29: 2, 27: 2, 25: 3, 22: 2,
            20: 2, 17: 2, 15: 2, 13: 3,
            10: 2,  8: 2
        ]
        cols -= colJump[cols] ?? 1
    }

    public func moreCols() {
        guard moreColsAreAvailable else { return }
        let colJump: [Int: Int] = [
             6: 2,  8: 2, 10: 3, 13: 2,
            15: 2, 18: 2, 20: 2, 22: 3,
            25: 2, 27: 2
        ]
        cols += colJump[cols] ?? 1
    }
}
