import SwiftUI

public enum PitchLabelType: String, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case letter      = "letter"
    case accidentals = "accidentals"
    case octave      = "octave"
    case fixedDo     = "fixed do"
    case month       = "month"
    case midi        = "midi"
    case wavelength  = "wavelength"
    case wavenumber  = "wavenumber"
    case period      = "period"
    case frequency   = "frequency"
    case cochlea     = "cochlea"
    case mode        = "mode"
    case map         = "guide"

    public static var pitchCases: [PitchLabelType] {
        return [.letter, .accidentals, .octave, .fixedDo, .month, .midi, .wavelength, .wavenumber, .period, .frequency, .cochlea]
    }

    public static var pitchClassCases: [PitchLabelType] {
        return [.letter, .accidentals, .fixedDo, .month]
    }
    
    public static var modeCases: [PitchLabelType] {
        return [.mode, .map]
    }

    public var id: String { self.rawValue }

    public var insetIcon: String {
        icon
    }
    
    public var icon: String {
        switch self {
        case .letter:      return "c.square"
        case .fixedDo:     return "person.2.wave.2"
        case .accidentals: return "number.square"
        case .octave:      return "4.square"
        case .midi:        return "60.square"
        case .wavelength:  return "ruler"
        case .wavenumber:  return "spatial.frequency"
        case .period:      return "stopwatch"
        case .frequency:   return "temporal.frequency"
        case .cochlea:     return "fossil.shell"
        case .mode:        return "building.columns"
        case .map:         return "map"
        case .month:       return "calendar"
        }
    }

    public var isCustomIcon: Bool {
        switch self {
        case .midi, .wavenumber, .frequency:
            return true
        default:
            return false
        }
    }

    // This is the label property that provides a string representation
    public var label: String {
        switch self {
        case .midi:
            return self.rawValue.uppercased()
        default:
            return self.rawValue.capitalized
        }
    }
}
