import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Bass: StringInstrument {
    public init(
        tonality: Tonality = Tonality(),
        pitches:  [Pitch] = Pitch.allPitches()
    ) {
        self.tonality = tonality
        self.pitches = pitches
    }
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.bass
    
    @Transient
    public var synthConductor: SynthConductor?

    @Transient
    public var midiConductor: MIDIConductor?

    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.bass.midiChannel.rawValue

    public var latching: Bool                     = false
    
    public var showOutlines: Bool               = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Bass.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [43, 38, 33, 28]

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Bass.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Bass.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

}
