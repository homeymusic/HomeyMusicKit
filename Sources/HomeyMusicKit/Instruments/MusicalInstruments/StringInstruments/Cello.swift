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

    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Transient
    public var intervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    public var midiInChannelMode:  MIDIChannelMode  = MIDIChannelMode.defaultIn
    public var midiOutChannelMode: MIDIChannelMode = MIDIChannelMode.defaultOut

    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentType.cello.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentType.cello.midiChannel.rawValue

    public var latching: Bool = false
    public var showMIDIVelocity: Bool = false
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    public var playSynthSounds: Bool = true

    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]
    
    public var pitchLabelTypes:    Set<PitchLabelType>    = Cello.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Cello.defaultIntervalLabelTypes
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
}
