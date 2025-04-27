import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Tonnetz: KeyboardInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.tonnetz
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted KeyboardInstrument state
    public var rows: Int = Tonnetz.defaultRows
    public var cols: Int = Tonnetz.defaultCols
    
    // — config constants (in-memory only)
    public static let defaultRows = 2, minRows = 1, maxRows = 4
    public static let defaultCols = 2, minCols = 1, maxCols = 5
    
    // — satisfy KeyboardInstrument’s visibility requirements
    public var defaultRows: Int { Self.defaultRows }
    public var minRows:     Int { Self.minRows     }
    public var maxRows:     Int { Self.maxRows     }
    
    public var defaultCols: Int { Self.defaultCols }
    public var minCols:     Int { Self.minCols     }
    public var maxCols:     Int { Self.maxCols     }
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Tonnetz.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Tonnetz.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    /// Designated init — call `Tonnetz()` or supply custom rows/cols
    public init() {}
    
    public var colIndices: [Int] {
        Array(-cols...cols)
    }
    
    // — override default layout
    public func colIndices(
        forTonic tonic: Int,
        pitchDirection: PitchDirection
    ) -> [Int] {
        Array(-cols...cols)
    }
    
    // — Tonnetz‐specific helpers
    public func noteNumber(
        row: Int,
        col: Int,
        offset: Int,
        tonalContext: TonalContext
    ) -> Int {
        if tonalContext.pitchDirection == .upward {
            return (7 * (col - offset)) + (4 * row)
        } else {
            return (-7 * (col - offset)) + (-4 * row)
        }
    }
    
    public func pitchClassMIDI(
        noteNumber: Int,
        tonalContext: TonalContext
    ) -> Int {
        let tonicNumber = Int(tonalContext.tonicPitch.midiNote.number)
        if tonalContext.pitchDirection == .upward {
            return tonicNumber + modulo(noteNumber, 12)
        } else {
            return tonicNumber - modulo(noteNumber, 12)
        }
    }
}
