import SwiftUI
import MIDIKitIO

public enum InstrumentChoice: Int, CaseIterable, Identifiable, Codable, Sendable {
    case tonnetz
    case linear
    case diamanti
    case piano
    case violin
    case cello
    case bass
    case banjo
    case guitar
    // TODO: rethink mode and tonic pickers as instruments
    case modePicker = 16 // above midi channel range
    case tonicPicker

    public var id: Self { self }
    
    public static let `default`: InstrumentChoice = .diamanti
    public static let defaultStringInstrumentChoice: InstrumentChoice = .violin

    public var label: String {
        if self == .tonicPicker {
            "tonic picker"
        } else if self == .modePicker {
            "mode picker"
        } else {
            String(describing: self)
        }
    }
    
    public var midiChannelLabel: String {
        if self == .tonicPicker {
            "NOT A MIDI INSTRUMENT"
        } else if self == .modePicker {
            "NOT A MIDI INSTRUMENT"
        } else {
            String(describing: Int(rawValue) + 1)
        }
    }

    public var midiChannel: MIDIChannel {
        if self == .tonicPicker {
            fatalError("Not a midi channel")
        } else if self == .modePicker {
            fatalError("Not a midi channel")
        } else {
            MIDIChannel(rawValue)
        }
    }
    
    public var icon: String {
        switch self {
        case .tonnetz:     return "circle.hexagongrid"
        case .linear:  return "rectangle.split.3x1"
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
        default:
            return icon
        }
    }

}

public extension InstrumentChoice {
    
    static var allInstruments: [InstrumentChoice] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [InstrumentChoice] {
        [.tonnetz, .linear, .diamanti, .piano]
    }
    
    static var stringInstruments: [InstrumentChoice] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }
    
    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }
    
    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
    
}
