import MIDIKitCore

public enum LayoutChoice: String, CaseIterable, Identifiable, Codable {
    case tonic = "tonic picker"
    case mode = "mode picker"
    case isomorphic = "isomorphic"
    case diamanti = "diamanti"
    case piano = "piano"
    case strings = "strings"
    
    public var id: String { self.rawValue }
    
    public var label: String { self.rawValue }

    public var icon: String {
        switch self {
        case .tonic: return "house"
        case .mode: return "building.columns"
        case .isomorphic: return "rectangle.split.2x1"
        case .diamanti: return "rectangle.split.2x2"
        case .piano: return "pianokeys"
        case .strings: return "guitars"
        }
    }

    public func midiChannel(stringsLayoutChoice: StringsLayoutChoice = .violin) -> MIDIChannel {
        return switch self {
        case .tonic: 15
        case .mode: 15
        case .isomorphic: 0
        case .diamanti: 1
        case .piano: 2
        case .strings: stringsLayoutChoice.midiChannel
        }
    }
    
    public var midiChannelLabel: String {
        String(Int(midiChannel()) + 1)
    }
    
    public static var allCases: [LayoutChoice] {
        return [.isomorphic, .diamanti, .piano, .strings]
    }
}
