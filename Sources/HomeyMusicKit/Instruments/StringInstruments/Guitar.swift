import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Guitar: StringInstrument {
    
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

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.guitar
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var allMIDIInChannels: Bool = false
    public var allMIDIOutChannels: Bool = false

    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentChoice.guitar.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentChoice.guitar.midiChannel.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Guitar.defaultOpenStringsMIDI
    
    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [64, 59, 55, 50, 45, 40]
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Guitar.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Guitar.defaultIntervalLabelChoices
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
}
