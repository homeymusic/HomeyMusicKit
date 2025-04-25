import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class ModePicker: KeyboardInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.modePicker
    public var latching: Bool                     = false

    // — persisted KeyboardInstrument state
    public var rows: Int = ModePicker.defaultRows
    public var cols: Int = ModePicker.defaultCols

    public init() {}

    // — transient UI state (not persisted)
    @Transient public var pitchOverlayCells:      [InstrumentCoordinate: OverlayCell] = [:]
    @Transient public var latchingTouchedPitches: Set<Pitch>                          = []

    // — config constants (in-memory only)
    public static let defaultRows = 0, minRows = 0, maxRows = 0
    public static let defaultCols = 6, minCols = 6, maxCols = 6

    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }

    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }
}
