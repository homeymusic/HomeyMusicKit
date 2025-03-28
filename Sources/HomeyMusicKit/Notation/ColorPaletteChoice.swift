public enum ColorPaletteChoice: String, CaseIterable, Identifiable, Codable, Sendable {
    case subtle = "subtle"
    case loud = "loud"
    case ebonyIvory = "piano"

    public var id: String { self.rawValue }

    public var icon: String {
        switch self {
        case .subtle: return "paintpalette"
        case .loud: return "paintpalette.fill"
        case .ebonyIvory: return "circle.lefthalf.filled"
        }
    }
    
    public var label: String {
        return self.rawValue.capitalized
    }
    
}
