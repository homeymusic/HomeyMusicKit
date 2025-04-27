import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Violin: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.violin
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Violin.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [76, 69, 62, 55]

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Violin.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Violin.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

    /// Designated init — you can call `Violin()` or supply a custom tuning
    public init() {}
}
	
