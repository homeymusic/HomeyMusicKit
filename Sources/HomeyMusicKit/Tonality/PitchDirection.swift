public enum PitchDirection: Int, CaseIterable, Identifiable, Sendable, IconRepresentable {
    
    case downward = 0
    case mixed    = 1
    case upward   = 2

    public var id: Int { self.rawValue }

    public static let `default`: PitchDirection = .upward
    
    public var icon: String {
        switch self {
        case .upward:   return "greaterthan.square"
        case .mixed:    return "equal.square"
        case .downward: return "lessthan.square"
        }
    }
    
    public var isUpward: Bool {
        switch self {
        case .downward:
            return false
        default:
            return true
        }
    }
    
    public var asciiSymbol: String {
        switch self {
        case .upward:   return ">"
        case .mixed:     return "="
        case .downward: return "<"
        }
    }
    
    public var majorMinor: MajorMinor {
        switch self {
        case .upward:   return .major
        case .mixed:     return .neutral
        case .downward: return .minor
        }
    }
    
    public var majorMinorMagnitude: Int {
        switch self {
        case .upward:   return 1
        case .mixed:     return 0
        case .downward: return -1
        }
    }
    public var isNatural: Bool {
        switch majorMinor {
        case .major:
            return true
        case .neutral:
            return true
        case .minor:
            return false
        }
    }

    public var shortHand: String {
        switch self {
        case .upward:   return ""
        case .mixed:     return ""
        case .downward: return "<"
        }
    }
    
    public var label: String {
        String(describing: self)
    }
}
