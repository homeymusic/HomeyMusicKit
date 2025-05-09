import SwiftData
import MIDIKitCore

@Model
public final class Linear: KeyboardInstrument {
    
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Transient
    public var intervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
#if os(macOS)
    public static let rowConfig = (default: 0, min: 0, max: 5)
    public static let colConfig = (default: 11, min: 6, max: 18)
#else
    public static let rowConfig = (default: 0, min: 0, max: 5)
    public static let colConfig = (default: 9, min: 6, max: 18)
#endif
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var midiInChannelMode:  MIDIChannelMode  = MIDIChannelMode.defaultIn
    public var midiOutChannelMode: MIDIChannelMode = MIDIChannelMode.defaultOut

    public var midiInChannelRawValue: MIDIChannelNumber = MusicalInstrumentType.linear.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = MusicalInstrumentType.linear.midiChannel.rawValue
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var latching: Bool      = false
    public var showOutlines: Bool  = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    public var playSynthSounds: Bool = true

    public var rows: Int = Linear.rowConfig.default
    public var cols: Int = Linear.colConfig.default
    
    public var pitchLabelTypes:    Set<PitchLabelType>    = Linear.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Linear.defaultIntervalLabelTypes
    
    @Relationship
    public var intervalColorPalette: IntervalColorPalette?
    
    @Relationship
    public var pitchColorPalette:    PitchColorPalette?
    
}
