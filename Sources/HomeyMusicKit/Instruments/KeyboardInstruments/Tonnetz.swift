import SwiftData
import MIDIKitCore

@Model
public final class Tonnetz: KeyboardInstrument {
    public static let rowConfig = (default: 2, min: 1, max: 4)
    public static let colConfig = (default: 2, min: 1, max: 5)

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.tonnetz
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()

    @Relationship
    public var tonality: Tonality

    @Transient
    public var synthConductor: SynthConductor?

    @Transient
    public var midiConductor: MIDIConductor?

    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.tonnetz.midiChannel.rawValue

    public var accidentalRawValue: Int = Accidental.default.rawValue

    public var latching: Bool = false
    public var showOutlines: Bool = true

    public var rows: Int = Tonnetz.rowConfig.default
    public var cols: Int = Tonnetz.colConfig.default

    public var pitchLabelChoices: Set<PitchLabelChoice> = Tonnetz.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Tonnetz.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?

    public init(tonality: Tonality = Tonality()) {
        self.tonality = tonality
    }
    
    public var colIndices: [Int] {
        Array(-cols...cols)
    }

    public func noteNumber(
        row: Int,
        col: Int,
        offset: Int
    ) -> Int {
        if pitchDirection == .upward {
            return (7 * (col - offset)) + (4 * row)
        } else {
            return (-7 * (col - offset)) + (-4 * row)
        }
    }

    public func pitchClassMIDI(
        noteNumber: Int
    ) -> Int {
        let tonicNumber = Int(tonicPitch.midiNote.number)
        if pitchDirection == .upward {
            return tonicNumber + modulo(noteNumber, 12)
        } else {
            return tonicNumber - modulo(noteNumber, 12)
        }
    }
}
