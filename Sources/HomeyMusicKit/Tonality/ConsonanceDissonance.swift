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
    
    case tonic
    case octave
    case maxPerfect
    case perfect
    case maxConsonant
    case consonant
    case dissonant
    case maxDissonant
    
    public var id: Int { self.rawValue }
    
    // TODO: change tonic to custom: inset.filled.nitterhouse
    public var icon: String {
        switch self {
        case .tonic: return "inset.filled.nitterhouse" // Nitterhouse
        case .octave: return "nitterhouse.fill"        // Nitterhouse
        case .perfect: return "triangle.fill"
        case .maxPerfect: return "inset.filled.triangle"
        case .consonant: return "diamond.fill"
        case .maxConsonant: return "inset.filled.diamond"
        case .dissonant: return "circle.fill"
        case .maxDissonant: return "inset.filled.circle"
        }
    }
    
    public var insetIcon: String {
        switch self {
        case .perfect: return "inset.filled.triangle"
        default:
            return icon
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
        case .tonic:        return "tonic"
        case .octave:       return "octave"
        case .perfect:      return "perfect"
        case .maxPerfect:   return "perfect (dominant)"
        case .consonant:    return "consonant"
        case .maxConsonant: return "consonant (characteristic)"
        case .dissonant:    return "dissonant"
        case .maxDissonant: return "dissonant (leading)"
        }
    }
    
    public var fontWeight: Font.Weight {
        switch self {
        case .tonic: return        .regular
        case .octave: return       .regular
        case .maxPerfect: return   .regular
        case .perfect: return      .regular
        case .maxConsonant: return .regular
        case .consonant: return    .regular
        case .dissonant: return    .regular
        case .maxDissonant: return .regular
        }
    }
    
    public var imageScale: CGFloat {
        switch self {
        case .tonic:        1.2
        case .octave:       1.0
        case .maxPerfect:   1.1
        case .perfect:      0.9
        case .maxConsonant: 1.0
        case .consonant:    0.8
        case .dissonant:    0.7
        case .maxDissonant: 0.9
        }
    }
    
    public static func < (lhs: ConsonanceDissonance, rhs: ConsonanceDissonance) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}
