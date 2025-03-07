import SwiftUI

// TODO: more levels:
// P1, P8: +4 House 100
// P4, P5: +3 Triangle 200
// m3, M6: +2 Diamond 300
// M3, m6: +1 Diamond 400
//     tt:  0 Stone 500
// M2, m7: -1 Stone 600
// m2, M7: -2 Stone 700

public enum ConsonanceDissonance: Int, CaseIterable, Identifiable, Comparable, Equatable, IconRepresentable {
    
    case tonic = 4
    case octave = 3
    case perfect = 2
    case consonant = 1
    case dissonant = 0
    
    public var id: Int { self.rawValue }
    
    public var icon: String {
        switch self {
        case .tonic: return "nitterhouse.fill"       // Nitterhouse
        case .octave: return "nitterhouse.fill"      // Nitterhouse
        case .perfect: return "triangle.fill"
        case .consonant: return "diamond.fill"
        case .dissonant: return "circle.fill"
        }
    }
    
    public var isCustomIcon: Bool {
        switch self {
        case .tonic, .octave:
            return true
        default:
            return false
        }
    }

    public var label: String {
        switch self {
        case .tonic: return "tonic"
        case .octave: return "octave"
        case .perfect: return "perfect"
        case .consonant: return "consonant"
        case .dissonant: return "dissonant"
        }
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    public var fontWeight: Font.Weight {
        switch self {
        case .tonic: return     .semibold
        case .octave: return    .regular
        case .perfect: return   .regular
        case .consonant: return .regular
        case .dissonant: return .regular
        }
    }
    
    public var imageScale: CGFloat {
        switch self {
        case .tonic:     0.7
        case .octave:    0.7
        case .perfect:   0.6
        case .consonant: 0.5
        case .dissonant: 0.4
        }
    }

    public static func < (lhs: ConsonanceDissonance, rhs: ConsonanceDissonance) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}
