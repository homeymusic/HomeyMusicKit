import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Violin: StringInstrument {
    
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var allMIDIInChannels: Bool = false
    public var allMIDIOutChannels: Bool = false
    
    public var midiInChannelRawValue: MIDIChannelNumber = MusicalInstrumentType.violin.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = MusicalInstrumentType.violin.midiChannel.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Violin.defaultOpenStringsMIDI
    
    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [76, 69, 62, 55]
    
    public var pitchLabelTypes:    Set<PitchLabelType>    = Violin.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Violin.defaultIntervalLabelTypes
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
}
	
