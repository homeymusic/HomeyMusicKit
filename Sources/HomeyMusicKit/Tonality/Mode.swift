import MIDIKitCore

public enum Mode: Int, CaseIterable, Identifiable, Comparable, Equatable, Sendable, IconRepresentable {
    case ionian               = 0
    case mixolydianPentatonic = 1
    case dorian               = 2
    case aeolianPentatonic    = 3
    case phrygian             = 4
    case lydian               = 5
    case ionianPentatonic     = 6
    case mixolydian           = 7
    case dorianPentatonic     = 8
    case aeolian              = 9
    case phrygianPentatonic   = 10
    case locrian              = 11
    
    public static let `default`: Mode = .ionian

    public var id: String { String(self.rawValue) }
    
    public static func < (lhs: Mode, rhs: Mode) -> Bool {
        lhs.majorMinor < rhs.majorMinor
    }

    public var scaleCount: ScaleCount {
        switch self {
        case .ionian, .dorian, .phrygian, .lydian, .mixolydian, .aeolian, .locrian:
            return .heptatonic
        case .mixolydianPentatonic, .aeolianPentatonic, .ionianPentatonic, .dorianPentatonic, .phrygianPentatonic:
            return .pentatonic
        }
    }
    
    public var majorMinorMagnitude: Int {
        switch self {
        case .lydian:               return 3
        case .ionian:               return 2
        case .ionianPentatonic:     return 2
        case .mixolydian:           return 1
        case .mixolydianPentatonic: return 1
        case .dorian:               return 0
        case .dorianPentatonic:     return 0
        case .aeolian:              return -1
        case .aeolianPentatonic:    return -1
        case .phrygian:             return -2
        case .phrygianPentatonic:   return -2
        case .locrian:              return -3
       }
    }
    
    public var majorMinor: MajorMinor {
        self.chordShape.majorMinor
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
    
    public var label: String {
        switch self {
        case .ionian:               return "major"
        case .mixolydianPentatonic: return "mixolydian pentatonic"
        case .dorian:               return "dorian"
        case .aeolianPentatonic:    return "minor pentatonic"
        case .phrygian:             return "phrygian"
        case .lydian:               return "lydian"
        case .ionianPentatonic:     return "major pentatonic"
        case .mixolydian:           return "mixolydian"
        case .dorianPentatonic:     return "dorian pentatonic"
        case .aeolian:              return "minor"
        case .phrygianPentatonic:   return "phrygian pentatonic"
        case .locrian:              return "locrian"
        }
    }
    
    public var shortHand: String {
        switch self {
        case .ionian:               return "MAJ"
        case .mixolydianPentatonic: return "mix"
        case .dorian:               return "DOR"
        case .aeolianPentatonic:    return "min"
        case .phrygian:             return "PHR"
        case .lydian:               return "LYD"
        case .ionianPentatonic:     return "maj"
        case .mixolydian:           return "MIX"
        case .dorianPentatonic:     return "dor"
        case .aeolian:              return "MIN"
        case .phrygianPentatonic:   return "phr"
        case .locrian:              return "LOC"
        }
    }
    
    public var pitchDirection: PitchDirection {
        switch self {
        case .ionian:               return .upward
        case .mixolydianPentatonic: return .downward
        case .dorian:               return .mixed
        case .aeolianPentatonic:    return .upward
        case .phrygian:             return .downward
        case .lydian:               return .upward
        case .ionianPentatonic:     return .upward
        case .mixolydian:           return .downward
        case .dorianPentatonic:     return .mixed
        case .aeolian:              return .upward
        case .phrygianPentatonic:   return .downward
        case .locrian:              return .downward
        }
    }
    
    public var chordShape: Chord {
        switch self {
        case .ionian:               return .positive
        case .mixolydianPentatonic: return .positive
        case .dorian:               return .positiveNegative
        case .aeolianPentatonic:    return .negative
        case .phrygian:             return .negative
        case .lydian:               return .positiveInversion
        case .ionianPentatonic:     return .positive
        case .mixolydian:           return .positive
        case .dorianPentatonic:     return .positiveNegative
        case .aeolian:              return .negative
        case .phrygianPentatonic:   return .negative
        case .locrian:              return .negativeInversion
        }
    }
    
    public var icon: String {
        switch self {
        case .ionianPentatonic: return "custom.plus.pentagon.fill"
        case .mixolydianPentatonic: return "custom.plus.pentagon.fill"
        case .dorianPentatonic: return "custom.plusminus.pentagon.fill"
        case .phrygianPentatonic: return "custom.minus.pentagon.fill"
        case .aeolianPentatonic: return "custom.minus.pentagon.fill"
        default:
            return chordShape.icon
        }
    }
    
    public var isCustomIcon: Bool {
        switch self {
        case .ionianPentatonic:
            return true
        case .mixolydianPentatonic:
            return true
        case .dorianPentatonic:
            return true
        case .phrygianPentatonic:
            return true
        case .aeolianPentatonic:
            return true
        default:
            return chordShape.isCustomIcon
        }
    }

    public var intervalClasses: [IntervalClass] {
        let ionianRawValues = [0, 2, 4, 5, 7, 9, 11].sorted()
        let phrygianRawValues = ionianRawValues.map { modulo(-$0, 12) }.sorted()
        var aeolianRawValues = phrygianRawValues; aeolianRawValues[1] = 2
        let mixolydianRawValues = aeolianRawValues.map { modulo(-$0, 12) }.sorted()
        var lydianRawValues = ionianRawValues; lydianRawValues[3] = 6
        let locrianRawValues = lydianRawValues.map { modulo(-$0, 12) }.sorted()
        var dorianRawValues = ionianRawValues; dorianRawValues[2] = 3; dorianRawValues[6] = 10

        var ionianPentatonicRawValues = ionianRawValues; ionianPentatonicRawValues.remove(at: 3); ionianPentatonicRawValues.remove(at: 5)
        var phrygianPentatonicRawValues = phrygianRawValues; phrygianPentatonicRawValues.remove(at: 1); phrygianPentatonicRawValues.remove(at: 3)
        var aeolianPentatonicRawValues = aeolianRawValues; aeolianPentatonicRawValues.remove(at: 1); aeolianPentatonicRawValues.remove(at: 4)
        var mixolydianPentatonicRawValues = mixolydianRawValues; mixolydianPentatonicRawValues.remove(at: 2); mixolydianPentatonicRawValues.remove(at: 5)
        var dorianPentatonicRawValues = dorianRawValues; dorianPentatonicRawValues.remove(at: 2); dorianPentatonicRawValues.remove(at: 4)
        
        switch self {
        case .ionian:               return ionianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .mixolydianPentatonic: return mixolydianPentatonicRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .dorian:               return dorianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .aeolianPentatonic:    return aeolianPentatonicRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .phrygian:             return phrygianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .lydian:               return lydianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .ionianPentatonic:     return ionianPentatonicRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .mixolydian:           return mixolydianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .dorianPentatonic:     return dorianPentatonicRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .aeolian:              return aeolianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .phrygianPentatonic:   return phrygianPentatonicRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        case .locrian:              return locrianRawValues.compactMap { IntervalClass(rawValue: UInt8($0)) }
        }
    }

}

public enum ScaleCount: Int, CaseIterable, Identifiable, Comparable, Equatable {
    case pentatonic = 5
    case heptatonic = 7
    
    public var id: String { String(self.rawValue) }
    
    public static func < (lhs: ScaleCount, rhs: ScaleCount) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var icon: String {
        switch self {
        case .heptatonic: return "7.square"
        case .pentatonic: return "pentagon.fill"
        }
    }
}

extension Mode {
    /// Returns all Mode cases starting with the given mode, then wrapping around.
    static func rotatedCases(startingWith mode: Mode) -> [Mode] {
        let cases = Mode.allCases
        guard let index = cases.firstIndex(of: mode) else {
            return cases // fallback if mode isn't found
        }
        // Create two slices: from the found index to the end, then from the start to the found index.
        let firstPart = cases[index...]
        let secondPart = cases[..<index]
        return Array(firstPart) + Array(secondPart)
    }
}
