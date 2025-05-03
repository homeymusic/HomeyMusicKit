import SwiftData

@Model
public final class Tonality {
    
    public var instruments: [any MusicalInstrument] {
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

    public var tonicPitch: Pitch {
      get { pitches[Int(tonicPitchRaw)] }
      set {
        tonicPitchRaw = newValue.midiNote.number
        broadcastChange(newValue) { midiConductor, updatedPitch, midiChannel in
          midiConductor.tonicPitch(updatedPitch, midiOutChannel: midiChannel)
        }
      }
    }
    public var tonicPitchRaw: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber

    public var pitchDirection: PitchDirection {
      get { PitchDirection(rawValue: pitchDirectionRaw) ?? .default }
      set {
        pitchDirectionRaw = newValue.rawValue
        broadcastChange(newValue) { midiConductor, updatedDirection, midiChannel in
          midiConductor.pitchDirection(updatedDirection, midiOutChannel: midiChannel)
        }
      }
    }
    public var pitchDirectionRaw: Int = PitchDirection.default.rawValue

    public var mode: Mode {
      get { Mode(rawValue: modeRaw) ?? .default }
      set {
        modeRaw = newValue.rawValue
        broadcastChange(newValue) { midiConductor, updatedMode, midiChannel in
          midiConductor.mode(updatedMode, midiOutChannel: midiChannel)
        }
      }
    }
    public var modeRaw: Int = Mode.default.rawValue

    public var accidental: Accidental {
      get { Accidental(rawValue: accidentalRawValue) ?? .default }
      set { accidentalRawValue = newValue.rawValue }
    }
    public var accidentalRawValue: Int = Accidental.default.rawValue


    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Transient
    public var intervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public init() {}
    
    public var activatedPitches: [Pitch] {
        pitches.filter{ $0.isActivated }
    }
    
    public func pitch(for midiNoteNumber: MIDINoteNumber) -> Pitch {
        pitches[Int(midiNoteNumber)]
    }

    public var octaveShift: Int {
        let defaultOctave = 4
        return tonicPitch.octave + (pitchDirection == .downward ? -1 : 0) - defaultOctave
    }
    
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) + 12)
    }
    
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) - 12)
    }
    
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number + 12)
        }
    }
    
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
        }
    }
    
    public func resetTonality() {
        tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber)
        mode = .default
        pitchDirection = .default
    }
    
    public var isDefaultTonality: Bool {
        isDefaultTonicPitch && isDefaultPitchDirection && isDefaultMode
    }
    
    public var isDefaultTonicPitch: Bool {
        tonicPitch.midiNote.number == Pitch.defaultTonicMIDINoteNumber
    }
    
    public var isDefaultMode: Bool {
        mode == Mode.default
    }
    
    public var isDefaultPitchDirection: Bool {
        pitchDirection == PitchDirection.default
    }
    
    func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return intervals[distance]!
    }
    
    
    /// Broadcast any tonality change to *all* attached instruments + their MIDI channels.
    private func broadcastChange<Value>(
      _ newValue: Value,
      using sendCC: (MIDIConductor, Value, MIDIChannel) -> Void
    ) {
      for instrument in instruments {
        guard let midiConductor = instrument.midiConductor else { continue }

        if instrument.allMIDIOutChannels {
          // send on channels 1…16
          for midiChannel in MIDIChannel.allCases {
            sendCC(midiConductor, newValue, midiChannel)
          }
        }
        else {
          // single‐channel case
          sendCC(midiConductor, newValue, instrument.midiOutChannel)
        }
      }
    }
}
