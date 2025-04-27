import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Banjo: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.banjo
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Banjo.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [62, 59, 55, 50, 62]
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Banjo.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Banjo.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    /// Designated init — you can call `Banjo()` or supply a custom tuning
    public init() {}
}
