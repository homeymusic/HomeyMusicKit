import SwiftData

@Model
public final class Tonality {
    
    public var musicalInstruments: [any MusicalInstrument] {
        tonnetzes as [any MusicalInstrument]
        + linears as [any MusicalInstrument]
        + diamantis as [any MusicalInstrument]
        + pianos as [any MusicalInstrument]
        + violins as [any MusicalInstrument]
        + cellos as [any MusicalInstrument]
        + basses as [any MusicalInstrument]
        + banjos as [any MusicalInstrument]
        + guitars as [any MusicalInstrument]
    }
    
    @Relationship(inverse: \Tonnetz.tonality)
    public var tonnetzes: [Tonnetz] = []
    
    @Relationship(inverse: \Linear.tonality)
    public var linears: [Linear] = []
    
    @Relationship(inverse: \Diamanti.tonality)
    public var diamantis: [Diamanti] = []
    
    @Relationship(inverse: \Piano.tonality)
    public var pianos: [Piano] = []
    
    @Relationship(inverse: \Violin.tonality)
    public var violins: [Violin] = []
    
    @Relationship(inverse: \Cello.tonality)
    public var cellos: [Cello] = []
    
    @Relationship(inverse: \Bass.tonality)
    public var basses: [Bass] = []
    
    @Relationship(inverse: \Banjo.tonality)
    public var banjos: [Banjo] = []
    
    @Relationship(inverse: \Guitar.tonality)
    public var guitars: [Guitar] = []
    
    public var tonicMIDINoteNumber: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    
    public var pitchDirectionRaw: Int = PitchDirection.default.rawValue
    
    public var modeRaw: Int = Mode.default.rawValue
        
    public var areModeAndTonicLinked: Bool = Tonality.modeAndTonicLinkDefault
    
    static let modeAndTonicLinkDefault: Bool = true
    
    public var isDefaultTonality: Bool {
        isDefaultTonicMIDINoteNumber &&
        isDefaultPitchDirectionRaw &&
        isDefaultModeRaw &&
        areModeAndTonicLinkedDefault
    }
    
    public var isDefaultTonicMIDINoteNumber: Bool {
        tonicMIDINoteNumber == Pitch.defaultTonicMIDINoteNumber
    }
    
    public var isDefaultPitchDirectionRaw: Bool {
        pitchDirectionRaw == PitchDirection.default.rawValue
    }
    
    public var isDefaultModeRaw: Bool {
        modeRaw == Mode.default.rawValue
    }
    
    public var areModeAndTonicLinkedDefault: Bool {
        areModeAndTonicLinked == Tonality.modeAndTonicLinkDefault
    }
    
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicMIDINoteNumber) + 12)
    }
    
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicMIDINoteNumber) - 12)
    }
    
    public var octaveShiftStatus: Int {
        let defaultOctave = 4
        return (Int(tonicMIDINoteNumber) / 12 - 1) + (pitchDirectionRaw == PitchDirection.downward.rawValue ? -1 : 0) - defaultOctave
    }
    
    var allActivatedPitches: [Pitch] {
        musicalInstruments
            .flatMap { $0.activatedPitches }
    }
    
    public init() {}
    
    /// Broadcast any tonality change to *all* attached instruments + their MIDI channels.
    public func broadcastChange<Value>(
        _ newValue: Value,
        using sendCC: (MIDIConductor, Value, MIDIChannel) -> Void
    ) {
        for instrument in musicalInstruments {
            guard let midiConductor = instrument.midiConductor else { continue }
            
            switch instrument.midiOutChannelMode {
            case .all:
                // Send on channels 1…16
                for midiChannel in MIDIChannel.allCases {
                    sendCC(midiConductor, newValue, midiChannel)
                }
                
            case .none:
                // Don't send anything
                continue
                
            case .selected:
                // Send only to instrument's selected channel
                sendCC(midiConductor, newValue, instrument.midiOutChannel)
            }
        }
    }
}
