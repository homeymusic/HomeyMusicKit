import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Banjo: StringInstrument {
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

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.banjo
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentChoice.banjo.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentChoice.banjo.midiChannel.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Banjo.defaultOpenStringsMIDI
    
    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [62, 59, 55, 50, 62]
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Banjo.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Banjo.defaultIntervalLabelChoices
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
}
