import SwiftUI

@available(macOS 11.0, iOS 13.0, *)
public enum IntervalLabelChoice: String, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case symbol          = "Symbol"
    case interval        = "Interval"
    case roman           = "Roman"
    case degree          = "Degree"
    case integer         = "Integer"
    case movableDo       = "Movable Do"
    case wavelengthRatio = "Wavelength Ratios"
    case wavenumberRatio = "Wavenumber Ratios"
    case periodRatio     = "Period Ratios"
    case frequencyRatio  = "Frequency Ratios"

    public var id: String { self.rawValue }

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
        case .movableDo:
            return "Movable Do"
        case .interval:
            return "Interval"
        case .roman:
            return "Roman Numeral"
        case .degree:
            return "Degree"
        case .integer:
            return "Integer Notation"
        case .wavelengthRatio:
            return "Wavelength Ratios"
        case .wavenumberRatio:
            return "Wavenumber Ratios"
        case .periodRatio:
            return "Period Ratios"
        case .frequencyRatio:
            return "Frequency Ratios"
        }
    }
    
    public static var intervalClassCases: [IntervalLabelChoice] {
        return [.symbol, .interval, .movableDo, .roman, .degree, .integer]
    }

}
