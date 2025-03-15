import SwiftUI
import MIDIKitIO

public enum InstrumentChoice: MIDIChannel, CaseIterable, Identifiable, Codable, Sendable {
    case tonnetz
    case isomorphic
    case diamanti
    case piano
    case violin
    case cello
    case bass
    case banjo
    case guitar
    case tonicPicker = 15

    public var id: Self { self }
    
    public var label: String {
        if self == .tonicPicker {
            "tonic picker"
        } else {
            String(describing: self)
        }
    }
    
    public var midiChannelLabel: String {
        String(describing: Int(rawValue) + 1)
    }

    public var icon: String {
        switch self {
        case .tonnetz:     return "circle.hexagongrid"
        case .isomorphic:  return "rectangle.split.3x1"
        case .diamanti:    return "diamond"
        case .piano:       return "pianokeys"
        case .violin:      return "guitars"
        case .cello:       return "guitars"
        case .bass:        return "guitars"
        case .banjo:       return "guitars"
        case .guitar:      return "guitars"
        case .tonicPicker: return "house"
        }
    }
}

public extension InstrumentChoice {
    
    static var allInstrumentTypes: [InstrumentChoice] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [InstrumentChoice] {
        [.tonnetz, .isomorphic, .diamanti, .piano]
    }
    
    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }
    
    static var stringInstruments: [InstrumentChoice] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }
    
    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
    
}
