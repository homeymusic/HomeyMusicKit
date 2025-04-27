import Foundation
import SwiftData
import MIDIKitIO

@Model
public class Piano: KeyboardInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.piano
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted KeyboardInstrument state
    public var rows: Int = Piano.defaultRows
    public var cols: Int = Piano.defaultCols

    // — config constants (in-memory only)
    public static let defaultRows = 0, minRows = 0, maxRows = 2
    public static let defaultCols = 8, minCols = 4, maxCols = 11

    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }

    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Piano.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Piano.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    public init() {}
    
    // — your tritone-centered layout hook
    public func colIndices(
        forTonic tonic: Int,
        pitchDirection: PitchDirection
    ) -> [Int] {
        let semis   = (pitchDirection == .downward) ? -6 : 6
        let tritone = tonic + semis
        let n       = cols
        guard n > 0 else { return [tritone] }

        var lower = tritone, found = 0, c = tritone - 1
        while found < n {
            if Pitch.isNatural(c) { lower = c; found += 1 }
            c -= 1
        }

        var upper = tritone; found = 0; c = tritone + 1
        while found < n {
            if Pitch.isNatural(c) { upper = c; found += 1 }
            c += 1
        }

        return Array(lower...upper)
    }
}
