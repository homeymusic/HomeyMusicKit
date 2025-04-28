import SwiftData

@Model
public final class Tonality {
  public var tonicPitch: MIDINoteNumber = Pitch.defaultTonicMIDINoteNumber

  // persist the raw values
  public var pitchDirectionRaw: Int = PitchDirection.default.rawValue
  public var modeRaw:           Int = Mode.default.rawValue

  // expose them as enums
  public var pitchDirection: PitchDirection {
    get { PitchDirection(rawValue: pitchDirectionRaw) ?? .default }
    set { pitchDirectionRaw = newValue.rawValue }
  }

  public var mode: Mode {
    get { Mode(rawValue: modeRaw) ?? .default }
    set { modeRaw = newValue.rawValue }
  }

  public init() {}
}
