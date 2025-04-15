public enum Chord: String, CaseIterable, Identifiable, Comparable, Equatable {
    case positive = "major"
    case negative = "minor"
    case positiveNegative = "mixed"
    case positiveInversion = "major inverted"
    case negativeInversion = "minor inverted"
    
    public var id: String { self.rawValue }
    
    public static func < (lhs: Chord, rhs: Chord) -> Bool {
        lhs.majorMinor < rhs.majorMinor
    }
    
    public var icon: String {
        switch self {
        case .positive:          return "plus.square.fill"
        case .positiveInversion: return "xmark.square.fill"
        case .negative:          return "minus.square.fill"
        case .negativeInversion: return "i.square.fill"
        case .positiveNegative:  return "plusminus"
        }
    }

    public var asciiSymbol: String {
        switch self {
        case .positive:          return "+"
        case .positiveInversion: return "x"
        case .negative:          return "-"
        case .negativeInversion: return "|"
        case .positiveNegative:  return "+/-"
        }
    }
    
    public var majorMinor: MajorMinor {
        switch self {
        case .positive:          return .major
        case .positiveInversion: return .major
        case .negative:          return .minor
        case .negativeInversion: return .minor
        case .positiveNegative:  return .neutral
        }
    }
    
    public var majorMinorMagnitude: Int {
        switch self {
        case .positiveInversion: return 2
        case .positive:          return 1
        case .positiveNegative:  return 0
        case .negative:          return -1
        case .negativeInversion: return -2
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

}
