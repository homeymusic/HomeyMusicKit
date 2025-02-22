@available(macOS 11.0, iOS 13.0, *)
public enum PitchDirection: Int, CaseIterable, Identifiable, Sendable, IconRepresentable {
    
    case upward   = 1
    case downward = -1
    case both     = 0

    public var id: Int { self.rawValue }

    public static let `default`: PitchDirection = .upward
    
    public var icon: String {
        switch self {
        case .upward:   return "greaterthan.square"
        case .both:     return "equal.square"
        case .downward: return "lessthan.square"
        }
    }
    
    public var isCustomIcon: Bool {
        switch self {
        default:
            return false
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
        case .both:     return "="
        case .downward: return "<"
        }
    }
    
    public var majorMinor: MajorMinor {
        switch self {
        case .upward:   return .major
        case .both:     return .neutral
        case .downward: return .minor
        }
    }

    public var shortHand: String {
        switch self {
        case .upward:   return ""
        case .both:     return ""
        case .downward: return "<"
        }
    }

    public var label: String {
        switch self {
        case .upward:   return "upward"
        case .both:     return "upward or downward"
        case .downward: return "downward"
        }
    }
}
