import SwiftUI

public enum IntervalClass: UInt8, CaseIterable, Identifiable, Comparable, Equatable {
    case P1
    case m2
    case M2
    case m3
    case M4
    case P4
    case tt
    case P5
    case m6
    case M6
    case m7
    case M7
    case P8
    
    public var id: UInt8 { self.rawValue }
    
    public static func < (lhs: IntervalClass, rhs: IntervalClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    // Custom initializer using distance value, with special handling for 0
    public init(distance: Int) {
        if distance == 0 {
            // If distance is exactly 0, map to P1 (unison)
            self = .P1
        } else {
            // Modulo operation to handle wrapping
            let moddeddistance = UInt8(modulo(Int(distance), 12))
            // If modulo result is 0, map to P8 (octave), otherwise use the raw value
            // this lets us treat the tonic pitch as special compared to all the octaves.
            if moddeddistance == 0 {
                self = .P8
            } else {
                self = IntervalClass(rawValue: moddeddistance)!
            }
        }
    }
    
    public var isTonic: Bool {
        self.rawValue == 0
    }
    
    public var isTritone: Bool {
        self.rawValue == 6
    }
    
    public var isOctave: Bool {
        self.rawValue == 12
    }
    
    public var majorMinor: MajorMinor {
        IntervalClass.majorMinor(intervalClass: self)
    }
    
    private static func majorMinor(intervalClass: IntervalClass) -> MajorMinor {
        switch intervalClass {
        case .m2, .m3, .m6, .m7:
            return .minor
        case .P1, .P4, .tt, .P5, .P8:
            return .neutral
        case .M2, .M4, .M6, .M7:
            return .major
        }
    }
    
    // when building UIs we need to know the how notes would behave above and
    // below the MIDI range so that the cells are aranged properly.
    // So we use these static functions to help us before we create stuff.
    public static func majorMinor(_ distance: Int) -> MajorMinor {
        majorMinor(intervalClass: IntervalClass(distance: distance))
    }
    
    public var consonanceDissonance: ConsonanceDissonance {
        switch self {
        case .P1:  // P1
            return .tonic
        case .P8:  // P8
            return .octave
        case .P4, .P5:  // P4, P5
            return .perfect
        case .m3, .M6:  // m3, M6
            return .consonant
        case .M4, .m6:  // M3, m6
            return .maxConsonant
        case .M2, .tt, .m7:  // M2, tt, m7
            return .dissonant
        case .m2, .M7:  // m2, M7
            return .maxDissonant
        }
    }
    
    @MainActor
    public func consonanceDissonance(for tonalContext: TonalContext) -> ConsonanceDissonance {
        if (self == .P5 && tonalContext.pitchDirection == .upward) ||
            (self == .P4 && tonalContext.pitchDirection == .downward){
            return .maxPerfect
        } else {
            return consonanceDissonance
        }
    }
    
    public var emoji: Image {
        Image(emojiFileName, bundle: .module)  // Load the image from the package's asset catalog
    }
    
    public var emojiFileName: String {
        switch self {
        case .P1:    // P1
            return "home_tortoise_tree"
        case .m2:     // m2
            return "stone_blue_hare"
        case .M2:     // M2
            return "stone_gold"
        case .m3:   // m3
            return "diamond_blue"
        case .M4:    // M3
            return "diamond_gold_sun"
        case .P4:    // P4
            return "tent_blue"
        case .tt:     // tt
            return "disco"
        case .P5:   // P5
            return "tent_gold"
        case .m6:   // m6
            return "diamond_blue_rain"
        case .M6:    // M6
            return "diamond_gold"
        case .m7:     // m7
            return "stone_blue"
        case .M7:  // M7
            return "stone_gold_hare"
        case .P8:  // P8
            return "home"
        }
    }
    
    public var movableDo: String {
        switch self {
        case .P1:    // P1
            return "Do"
        case .m2:     // m2
            return "Di Ra"
        case .M2:     // M2
            return "Re"
        case .m3:   // m3
            return "Ri Me"
        case .M4:    // M3
            return "Mi"
        case .P4:    // P4
            return "Fa"
        case .tt:     // tt
            return "Fi Se"
        case .P5:   // P5
            return "Sol"
        case .m6:   // m6
            return "Si Le"
        case .M6:    // M6
            return "La"
        case .m7:     // m7
            return "Li Te"
        case .M7:  // M7
            return "Ti"
        case .P8:  // P8
            return "Do"
        }
    }
    
    // pitch-direction-dependent attributes
    
    public func degree(for pitchDirection: PitchDirection) -> String {
        let caret: String = "\u{0302}"
        var accidental: Accidental = majorMinor.accidental(for: pitchDirection)
        if isTritone {
            accidental = pitchDirection.isUpward ? .sharp : .flat
        }
        return "\(pitchDirection.shortHand)\(accidental.label)\(degreeQuantity(for: pitchDirection).rawValue)\(caret)"
    }
    
    public func roman(for pitchDirection: PitchDirection) -> String {
        var accidental: Accidental = majorMinor.accidental(for: pitchDirection)
        if isTritone {
            accidental = pitchDirection.isUpward ? .sharp : .flat
        }
        return "\(pitchDirection.shortHand)\(accidental.label)\(degreeQuantity(for: pitchDirection).rawValue.romanNumeral)"
    }
    
    public func shorthand(for pitchDirection: PitchDirection) -> String {
        if isTritone {
            return "\(pitchDirection.shortHand)tt"
        } else {
            return "\(pitchDirection.shortHand)\(majorMinor.shortHand)\(degreeQuantity(for: pitchDirection).rawValue)"
        }
    }
        
    public func label(for pitchDirection: PitchDirection) -> String {
        if isTritone {
            return "\(pitchDirection.label) tritone"
        } else {
            return "\(pitchDirection.label) \(majorMinor.label) \(degreeQuantity(for: pitchDirection).label)"
        }
    }

    // private helper functions
        
    public enum DegreeQuantity: Int {
        case one    = 1
        case two    = 2
        case three  = 3
        case four   = 4
        case five   = 5
        case six    = 6
        case seven  = 7
        case eight  = 8
        
        var label: String {
            switch self {
            case .one:     return "first"
            case .two:     return "second"
            case .three:   return "third"
            case .four:    return "fourth"
            case .five:    return "fifth"
            case .six:     return "sixth"
            case .seven:   return "seventh"
            case .eight:   return "eighth"
            }
        }
    }

    public func degreeQuantity(for pitchDirection: PitchDirection) -> DegreeQuantity {
        if pitchDirection.isUpward {
            switch self {
            case .P1:   // 0
                return .one
            case .m2:    // 1
                return .two
            case .M2:    // 2
                return .two
            case .m3:  // 3
                return .three
            case .M4:   // 4
                return .three
            case .P4:   // 5
                return .four
            case .tt:    // 6
                return .four
            case .P5:  // 7
                return .five
            case .m6:  // 8
                return .six
            case .M6:   // 9
                return .six
            case .m7:    // 10
                return .seven
            case .M7: // 11
                return .seven
            case .P8: // 12
                return .eight
            }
        } else {
            switch self {
            case .P1:   // 0
                return .one
            case .m7:    // 10
                return .two
            case .M7: // 11
                return .two
            case .m2:    // 1
                return .seven
            case .M2:    // 2
                return .seven
            case .m3:  // 3
                return .six
            case .M4:   // 4
                return .six
            case .P4:   // 5
                return .five
            case .tt:    // 6
                return .four
            case .P5:  // 7
                return .four
            case .m6:  // 8
                return .three
            case .M6:   // 9
                return .three
            case .P8: // 12
                return .eight
            }
        }
    }
        
}
