import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class TonicPicker: KeyboardInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.tonicPicker
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted KeyboardInstrument state
    public var rows: Int = TonicPicker.defaultRows
    public var cols: Int = TonicPicker.defaultCols
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = [PitchLabelChoice.letter]
    public var intervalLabelChoices: Set<IntervalLabelChoice> = [IntervalLabelChoice.symbol]

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    public init() {}

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
