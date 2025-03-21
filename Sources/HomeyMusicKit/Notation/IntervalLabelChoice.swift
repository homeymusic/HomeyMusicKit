import SwiftUI

@available(macOS 11.0, iOS 13.0, *)
public enum IntervalLabelChoice: String, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case symbol          = "Symbol"
    case interval        = "Interval"
    case movableDo       = "Movable Do"
    case roman           = "Roman"
    case degree          = "Degree"
    case integer         = "Integer"
    case wavelengthRatio = "Wavelength Ratios"
    case wavenumberRatio = "Wavenumber Ratios"
    case periodRatio     = "Period Ratios"
    case frequencyRatio  = "Frequency Ratios"

    public var id: String { self.rawValue }

    public var insetIcon: String {
        icon
    }
    
    public var icon: String {
        switch self {
        case .symbol:          return "nitterhouse.fill"
        case .interval:        return "p1.button.horizontal"
        case .movableDo:       return "person.wave.2"
        case .roman:           return "i.square"
        case .degree:          return "control"
        case .integer:         return "0.square"
        case .wavelengthRatio: return "ruler"
        case .wavenumberRatio: return "spatial.frequency"
        case .periodRatio:     return "stopwatch"
        case .frequencyRatio:  return "temporal.frequency"
        }
    }

    public var isCustomIcon: Bool {
        switch self {
        case .symbol, .wavenumberRatio, .frequencyRatio:
            return true
        default:
            return false
        }
    }

    // Add the `label` property to provide a formatted string representation
    public var label: String {
        switch self {
        case .symbol:
            return "Symbol"
        case .interval:
            return "Interval"
        case .movableDo:
            return "Movable Do"
        case .roman:
            return "Roman Numeral"
        case .degree:
            return "Degree"
        case .integer:
            return "Integer"
        case .wavelengthRatio:
            return "Wavelength Ratio"
        case .wavenumberRatio:
            return "Wavenumber Ratio"
        case .periodRatio:
            return "Period Ratio"
        case .frequencyRatio:
            return "Frequency Ratio"
        }
    }
    
    public static var intervalClassCases: [IntervalLabelChoice] {
        return [.symbol, .interval, .movableDo, .roman, .degree, .integer]
    }

}
