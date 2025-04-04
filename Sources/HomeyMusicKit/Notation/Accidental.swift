public enum Accidental: Int, CaseIterable, Identifiable, Sendable {
    case flat    = -1
    case none    = 0
    case sharp   = 1

    public var id: Int { self.rawValue }
     
    public static let `default`: Accidental = .flat

    public var icon: String {
        asciiSymbol
    }

    public var asciiSymbol: String {
        switch self {
        case .flat:  return "♭"
        case .none:  return ""
        case .sharp: return "♯"
        }
    }
    
    public var majorMinor: MajorMinor {
        switch self {
        case .flat:  return .minor
        case .none:  return .neutral
        case .sharp: return .major
        }
    }

    public var shortHand: String {
        return asciiSymbol
    }

    public var label: String {
        return asciiSymbol
    }
    
}

extension Accidental {
    public static var displayCases: [Accidental] {
        allCases.filter { $0 != .none }
    }
}
