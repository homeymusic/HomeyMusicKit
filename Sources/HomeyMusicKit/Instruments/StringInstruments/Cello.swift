import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Cello: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.cello
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    public var tonicPitchMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    public var pitchDirectionRawValue: Int = PitchDirection.default.rawValue
    public var modeRawValue: Int       = Mode.default.rawValue
    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.cello.midiChannel.rawValue

    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int]

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]

    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Cello.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Cello.defaultIntervalLabelChoices

    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
    /// Designated init — you can call `Cello()` or supply a custom tuning
    public init(openStringsMIDI: [Int] = defaultOpenStringsMIDI) {
        self.openStringsMIDI = openStringsMIDI
    }
}
