import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Cello: StringInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.cello
    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int]

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Cello.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Cello.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
    /// Designated init — you can call `Cello()` or supply a custom tuning
    public init(openStringsMIDI: [Int] = defaultOpenStringsMIDI) {
        self.openStringsMIDI = openStringsMIDI
    }
}
