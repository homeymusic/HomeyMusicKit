import SwiftData
import MIDIKitCore

@Model
public final class Piano: KeyboardInstrument {
    
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
    public static let rowConfig = (default: 0, min: 0, max: 2)
    public static let colConfig = (default: 11, min: 4, max: 32)
#else
    public static let rowConfig = (default: 0, min: 0, max: 2)
    public static let colConfig = (default: 8, min: 4, max: 11)
#endif
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var midiInChannelMode:  MIDIChannelMode  = MIDIChannelMode.defaultIn
    public var midiOutChannelMode: MIDIChannelMode = MIDIChannelMode.defaultOut

    public var midiInChannelRawValue: MIDIChannelNumber = MIDIInstrumentType.piano.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = MIDIInstrumentType.piano.midiChannel.rawValue
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var latching: Bool = false
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    public var playSynthSounds: Bool = true

    public var rows: Int = Piano.rowConfig.default
    public var cols: Int = Piano.colConfig.default
    
    public var pitchLabelTypes: Set<PitchLabelType> = Piano.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Piano.defaultIntervalLabelTypes
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?
    
    public func colIndices(
        forTonic tonic: Int,
        pitchDirection: PitchDirection
    ) -> [Int] {
        let semis = (pitchDirection == .downward) ? -6 : 6
        let tritone = tonic + semis
        let n = cols
        guard n > 0 else { return [tritone] }
        
        var lower = tritone, found = 0, c = tritone - 1
        while found < n {
            if Pitch.isNatural(c) { lower = c; found += 1 }
            c -= 1
        }
        
        var upper = tritone; found = 0; c = tritone + 1
        while found < n {
            if Pitch.isNatural(c) { upper = c; found += 1 }
            c += 1
        }
        
        return Array(lower...upper)
    }
}
