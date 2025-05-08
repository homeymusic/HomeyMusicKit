public enum MIDIChannelMode: String, CaseIterable, Codable, Equatable, Sendable {
    case all
    case none
    case selected
    
    public static let `default`: MIDIChannelMode = .selected

}
