import SwiftUI
import MIDIKitCore

public enum InstrumentType: Int, CaseIterable, Identifiable, Codable, Sendable {
    case tonnetz       // rawValue 0
    case linear        // 1
    case diamanti      // 2
    case piano         // 3
    case violin        // 4
    case cello         // 5
    case bass          // 6
    case banjo         // 7
    case guitar        // 8
    // above the 0–15 MIDI channel range:
    case modePicker    = 16
    case tonicPicker   = 17

    // MARK: - Identifiable
    public var id: Self { self }

    // MARK: - Defaults
    public static let `default`: InstrumentType = .diamanti
    public static let defaultStringInstrumentType: InstrumentType = .violin

    // MARK: - Display Label
    public var label: String {
        switch self {
        case .modePicker:  return "mode picker"
        case .tonicPicker: return "tonic picker"
        default:           return String(describing: self)
        }
    }

    // MARK: - MIDI Channel
    /// Crashes if you ask for a channel on a non-MIDI picker.
    public var midiChannel: MIDIChannel {
        guard ![.modePicker, .tonicPicker].contains(self),
              let ch = MIDIChannel(rawValue: UInt4(rawValue))
        else {
            fatalError("InstrumentType '\(self)' is not a MIDI channel")
        }
        return ch
    }

    /// 1-based string from your MIDIChannel enum
    public var midiChannelLabel: String {
        midiChannel.label
    }

    // MARK: - Icons
    public var icon: String {
        switch self {
        case .tonnetz:     return "circle.hexagongrid"
        case .linear:      return "rectangle.split.3x1"
        case .diamanti:    return "diamond"
        case .piano:       return "pianokeys"
        case .violin:      return "guitars"
        case .cello:       return "guitars"
        case .bass:        return "guitars"
        case .banjo:       return "guitars"
        case .guitar:      return "guitars"
        case .modePicker:  return "location.viewfinder"
        case .tonicPicker: return "house"
        }
    }

    public var filledIcon: String {
        switch self {
        case .modePicker:  return "location.square.fill"
        case .tonicPicker: return "house.fill"
        default:           return icon
        }
    }
}

public extension InstrumentType {
    static var allInstruments: [InstrumentType] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [InstrumentType] {
        [.tonnetz, .linear, .diamanti, .piano]
    }

    static var stringInstruments: [InstrumentType] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }

    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }

    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
}
