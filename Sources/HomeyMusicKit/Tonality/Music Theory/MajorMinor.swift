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
    
    public var insetIcon: String {
        icon
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
            return Self.minorColor
        case .neutral:
            return Self.neutralColor
        case .major:
            return Self.majorColor
        }
    }

    @available(iOS 13.0, *)
    public var grayscaleColor: Color {
        switch self {
        case .minor:
            return Color.systemGray4
        case .neutral:
            return Color.systemGray
        case .major:
            return .white
        }
    }
    
    public static let minorColor: Color = Color(.sRGB, red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, opacity: 1.0)
    public static let neutralColor: Color = Color(.sRGB, red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, opacity: 1.0)
    public static let majorColor: Color = Color(.sRGB, red: 1, green: 0.6745098039, blue: 0.2, opacity: 1.0)
    public static let altNeutralColor: Color = Color(.sRGB, red: 1.0, green: 0.333333, blue: 0.0, opacity: 1.0)

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
