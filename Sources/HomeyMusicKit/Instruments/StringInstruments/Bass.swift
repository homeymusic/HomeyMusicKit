import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Bass: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.bass
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue
    public var modeRawValue: Int       = Mode.default.rawValue
    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.bass.midiChannel.rawValue

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
