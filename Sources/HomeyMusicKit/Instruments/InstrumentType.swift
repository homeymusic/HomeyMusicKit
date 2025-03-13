import SwiftUI
import MIDIKitIO

public enum InstrumentType: MIDIChannel, CaseIterable, Identifiable, Codable {
    case isomorphic  = 0
    case diamanti    = 1
    case piano       = 2
    case violin      = 3
    case cello       = 4
    case bass        = 5
    case banjo       = 6
    case guitar      = 7
    case tonicPicker = 15

    public var id: Self { self }
    
    public var label: String {
        String(describing: self)
    }
    
    public var icon: String {
        switch self {
        case .isomorphic:  return "rectangle.split.2x1"
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
        [.isomorphic, .diamanti, .piano]
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
