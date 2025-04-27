import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Bass: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.bass
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Bass.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [43, 38, 33, 28]

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Bass.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Bass.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    /// Designated init — you can call `Bass()` or supply a custom tuning
    public init() {}
}
