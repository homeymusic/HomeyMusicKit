import SwiftUI

// TODO: more levels:
//         M3, m6: ±4
//         m3, M6: ±3
//         M2, m7: ±2
// P4, P5, m2, M7: ±1
//     P1, P8, tt: 0

@available(macOS 11.0, iOS 13.0, *)
public enum MajorMinor: Int, CaseIterable, Identifiable, Comparable, Equatable, IconRepresentable {
    case major   =  1
    case neutral =  0
    case minor   = -1
    
    public var id: Int { self.rawValue }

    public var label: String {
        switch self {
        case .major:   return "major"
        case .neutral: return "perfect"
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
    
    public var icon: String {
        switch self {
        default:
            return "paintbrush.pointed.fill"
        }
    }
    
    public var isCustomIcon: Bool {
        switch self {
        default:
            return false
        }
    }
    
    @available(iOS 13.0, *)
    public var color: Color {
        switch self {
        case .minor:
            return Color(.sRGB, red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, opacity: 1.0)
        case .neutral:
            return Color(.sRGB, red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, opacity: 1.0)
        case .major:
            return Color(.sRGB, red: 1, green: 0.6745098039, blue: 0.2, opacity: 1.0)
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

    public static let altNeutralColor: Color = Color(.sRGB, red: 1.0, green: 0.333333, blue: 0.0, opacity: 1.0)
    
    public static func < (lhs: MajorMinor, rhs: MajorMinor) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}
