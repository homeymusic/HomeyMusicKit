import SwiftUI
import MIDIKitIO

public enum InstrumentType: MIDIChannel, CaseIterable, Identifiable, Codable {
    case isomorphic  = 0
    case tonnetz     = 1
    case diamanti    = 2
    case piano       = 3
    case violin      = 4
    case cello       = 5
    case bass        = 6
    case banjo       = 7
    case guitar      = 8
    case tonicPicker = 15

    public var id: Self { self }
    
    public var label: String {
        String(describing: self)
    }
    
    public var icon: String {
        switch self {
        case .isomorphic:  return "rectangle.split.3x1"
        case .tonnetz:     return "circle.hexagongrid"
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

public extension InstrumentType {
    
    static var allInstrumentTypes: [InstrumentType] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [InstrumentType] {
        [.isomorphic, .tonnetz, .diamanti, .piano]
    }
    
    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }
    
    static var stringInstruments: [InstrumentType] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }
    
    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
    
}
