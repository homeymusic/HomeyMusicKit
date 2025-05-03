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
    
    public static let rowConfig = (default: 0, min: 0, max: 5)
    public static let colConfig = (default: 9, min: 6, max: 18)

    public var instrumentType: InstrumentType = InstrumentType.linear
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?

    public var allMIDIInChannels: Bool = false
    public var allMIDIOutChannels: Bool = false

    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentType.linear.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentType.linear.midiChannel.rawValue

    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool      = false
    public var showOutlines: Bool  = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    
    public var rows: Int = Linear.rowConfig.default
    public var cols: Int = Linear.colConfig.default

    public var pitchLabelTypes:    Set<PitchLabelType>    = Linear.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Linear.defaultIntervalLabelTypes

    @Relationship
    public var intervalColorPalette: IntervalColorPalette?
    
    @Relationship
    public var pitchColorPalette:    PitchColorPalette?

}
