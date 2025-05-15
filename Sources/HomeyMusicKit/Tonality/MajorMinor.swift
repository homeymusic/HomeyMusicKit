import SwiftUI

public enum MajorMinor: Int, CaseIterable, Identifiable, Comparable, Equatable, IconRepresentable {
    case major   =  1
    case neutral =  0
    case minor   = -1
    
    public var id: Int { self.rawValue }

    public var label: String {
        switch self {
        case .major:   return "major"
        case .neutral: return "neutral"
        case .minor:   return "minor"
        }
    }
    
    public var complement: MajorMinor {
        switch self {
        case .major:   return .minor
        case .neutral: return .neutral
        case .minor:   return .major
        }
    }
    
    public var majorMinorMagnitude: Int {
        self.rawValue
    }
    
    public var icon: String {
        switch self {
        default:
            return "paintbrush.pointed.fill"
        }
    }
    
    public var shortHand: String {
        switch self {
        case .minor:   return "m"
        case .major:   return "M"
        case .neutral: return "P"
        }
    }
    
    public func accidental(for pitchDirection: PitchDirection) -> Accidental {
        switch self {
        case .major:
            return pitchDirection.isUpward ? .none : .sharp
        case .neutral:
            return .none
        case .minor:
            return pitchDirection.isUpward ? .flat : .none
        }
    }
    
    public static func < (lhs: MajorMinor, rhs: MajorMinor) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}
