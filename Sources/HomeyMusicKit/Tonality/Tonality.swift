import SwiftData

@Model
public final class Tonality {
    var tonicPitch: Pitch {
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
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    public init() {}
}
