import SwiftData
import MIDIKitCore

@Model
public final class Diamanti: KeyboardInstrument {
    
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

    public static let rowConfig = (default: 0, min: 0, max: 2)
    public static let colConfig = (default: 13, min: 6, max: 18)

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.diamanti
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?

    public var allMIDIInChannels: Bool = false
    public var allMIDIOutChannels: Bool = false

    public var midiInChannelRawValue: MIDIChannelNumber = InstrumentChoice.diamanti.midiChannel.rawValue
    public var midiOutChannelRawValue: MIDIChannelNumber = InstrumentChoice.diamanti.midiChannel.rawValue

    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool = false
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = false
    
    public var rows: Int = Diamanti.rowConfig.default
    public var cols: Int = Diamanti.colConfig.default

    public var pitchLabelChoices: Set<PitchLabelChoice> = Diamanti.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Diamanti.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?
    
    public func fewerCols() {
        guard fewerColsAreAvailable else { return }
        let jumps: [Int: Int] = [
            29: 2, 27: 2, 25: 3, 22: 2,
            20: 2, 17: 2, 15: 2, 13: 3,
            10: 2, 8: 2
        ]
        cols -= jumps[cols] ?? 1
    }

    public func moreCols() {
        guard moreColsAreAvailable else { return }
        let jumps: [Int: Int] = [
            6: 2, 8: 2, 10: 3, 13: 2,
            15: 2, 18: 2, 20: 2, 22: 3,
            25: 2, 27: 2
        ]
        cols += jumps[cols] ?? 1
    }
}
