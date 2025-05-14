import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Bass: StringInstrument {
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

    public var midiInChannelRawValue: MIDIChannelNumber = MIDIInstrumentType.bass.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = MIDIInstrumentType.bass.midiChannel.rawValue

    public var latching: Bool                     = false
    public var showMIDIVelocity: Bool = false
    public var showOutlines: Bool               = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    public var playSynthSounds: Bool = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Bass.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [43, 38, 33, 28]

    public var pitchLabelTypes:    Set<PitchLabelType>    = Bass.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = Bass.defaultIntervalLabelTypes

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?

}
