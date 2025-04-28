import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Cello: StringInstrument {
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.cello
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var synthConductor: SynthConductor?
    
    @Transient
    public var midiConductor: MIDIConductor?
    
    public var accidentalRawValue: Int = Accidental.default.rawValue
    public var midiChannelRawValue: MIDIChannelNumber = InstrumentChoice.cello.midiChannel.rawValue
    
    public var latching: Bool = false
    public var showOutlines: Bool = true
    
    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Cello.defaultOpenStringsMIDI
    
    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]
    
    public var pitchLabelChoices:    Set<PitchLabelChoice>    = Cello.defaultPitchLabelChoices
    public var intervalLabelChoices: Set<IntervalLabelChoice> = Cello.defaultIntervalLabelChoices
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette:    PitchColorPalette?
    
    /// Designated init — you can call `Cello()` or supply a custom tuning
    public init(tonality: Tonality = Tonality()) {
        self.tonality = tonality
    }
}
