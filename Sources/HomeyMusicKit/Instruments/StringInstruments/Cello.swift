import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Cello: StringInstrument {

    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    @Relationship
    public var tonality: Tonality

    public var instrumentType: InstrumentType = InstrumentType.cello
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var allMIDIInChannels: Bool = false
    public var allMIDIOutChannels: Bool = false

    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentType.cello.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentType.cello.midiChannel.rawValue

    public var latching: Bool = false
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Cello.defaultOpenStringsMIDI
    
    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Cello.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Cello.defaultIntervalLabelChoices
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
}
