import SwiftData

@Model
public final class Tonality {
    
    public var tonicPitch: Pitch {
        get {
            pitches[Int(tonicPitchRaw)]
        }
        set {
            tonicPitchRaw = newValue.midiNote.number
        }
    }
    public var tonicPitchRaw: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber
    
    public var pitchDirection: PitchDirection {
        get {
            PitchDirection(rawValue: pitchDirectionRaw) ?? .default
        }
        set {
            pitchDirectionRaw = newValue.rawValue
        }
    }
    public var pitchDirectionRaw: Int = PitchDirection.default.rawValue
    
    public var mode: Mode {
        get {
            Mode(rawValue: modeRaw) ?? .default
        }
        set {
            modeRaw = newValue.rawValue
        }
    }
    public var modeRaw:           Int = Mode.default.rawValue
        
    public var accidental: Accidental {
        get {
            Accidental(rawValue: accidentalRawValue) ?? .default
        }
        set {
            accidentalRawValue = newValue.rawValue
        }
    }
    public var accidentalRawValue: Int  = Accidental.default.rawValue    

    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    public init() {}
    
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
    
}
