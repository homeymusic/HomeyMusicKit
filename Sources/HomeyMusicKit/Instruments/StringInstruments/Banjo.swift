import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Banjo: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.banjo
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()

    @Transient
    public var synthConductor: SynthConductor?

    @Transient
    public var midiConductor: MIDIConductor?

    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue
    public var modeRawValue: Int       = Mode.default.rawValue
    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.banjo.midiChannel.rawValue

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
