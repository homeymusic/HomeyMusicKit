import SwiftUI

public enum IntervalClass: UInt8, CaseIterable, Identifiable, Comparable, Equatable {
    case zero   = 0
    case one    = 1
    case two    = 2
    case three  = 3
    case four   = 4
    case five   = 5
    case six    = 6
    case seven  = 7
    case eight  = 8
    case nine   = 9
    case ten    = 10
    case eleven = 11
    case twelve = 12
    
    public var id: UInt8 { self.rawValue }
    
    public static func < (lhs: IntervalClass, rhs: IntervalClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    // Custom initializer using distance value, with special handling for 0
    public init(distance: Int) {
        if distance == 0 {
            // If distance is exactly 0, map to P1 (unison)
            self = .zero
        } else {
            // Modulo operation to handle wrapping
            let moddeddistance = UInt8(modulo(Int(distance), 12))
            // If modulo result is 0, map to P8 (octave), otherwise use the raw value
            // this lets us treat the tonic pitch as special compared to all the octaves.
            // TODO: each voice should have its own tonicPitch and therefore its own TonalContext
            // the tonic pitch class would be the same across voices
            if moddeddistance == 0 {
                self = .twelve
            } else if let intervalClass = IntervalClass(rawValue: moddeddistance) {
                self = intervalClass
            } else {
                fatalError("Invalid distance value: \(distance)")
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
        case .one, .three, .six, .eight, .ten:
            return .minor
        case .zero, .five, .seven, .twelve:
            return .neutral
        case .two, .four, .nine, .eleven:
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
        case .zero:  // P1
            return .tonic
        case .twelve:  // P8
            return .octave
        case .five, .seven:  // P4, P5
            return .perfect
        case .three, .four, .eight, .nine:  // m3, M3, m6, M6
            return .consonant
        case .one, .two, .six, .ten, .eleven:  // m2, M2, tt, m7, M7
            return .dissonant
        }
    }
    
    public var emoji: Image {
        Image(emojiFileName, bundle: .module)  // Load the image from the package's asset catalog
    }
    
    private var emojiFileName: String {
        switch self {
        case .zero:    // P1
            return "home_tortoise_tree"
        case .one:     // m2
            return "stone_blue_hare"
        case .two:     // M2
            return "stone_gold"
        case .three:   // m3
            return "diamond_blue"
        case .four:    // M3
            return "diamond_gold_sun"
        case .five:    // P4
            return "tent_blue"
        case .six:     // tt
            return "disco"
        case .seven:   // P5
            return "tent_gold"
        case .eight:   // m6
            return "diamond_blue_rain"
        case .nine:    // M6
            return "diamond_gold"
        case .ten:     // m7
            return "stone_blue"
        case .eleven:  // M7
            return "stone_gold_hare"
        case .twelve:  // P8
            return "home"
        }
    }
    
    public var movableDo: String {
        switch self {
        case .zero:    // P1
            return "Do"
        case .one:     // m2
            return "Di Ra"
        case .two:     // M2
            return "Re"
        case .three:   // m3
            return "Ri Me"
        case .four:    // M3
            return "Mi"
        case .five:    // P4
            return "Fa"
        case .six:     // tt
            return "Fi Se"
        case .seven:   // P5
            return "Sol"
        case .eight:   // m6
            return "Si Le"
        case .nine:    // M6
            return "La"
        case .ten:     // m7
            return "Li Te"
        case .eleven:  // M7
            return "Ti"
        case .twelve:  // P8
            return "Do"
        }
    }
    
    // pitch-direction-dependent attributes
    
    public func degree(for pitchDirection: PitchDirection) -> String {
        let caret: String = "\u{0302}"
        return "\(pitchDirection.shortHand)\(majorMinor.accidental(for: pitchDirection).label)\(degreeQuantity(for: pitchDirection).rawValue)\(caret)"
    }
    
    public func roman(for pitchDirection: PitchDirection) -> String {
        "\(pitchDirection.shortHand)\(majorMinor.accidental(for: pitchDirection).label)\(degreeQuantity(for: pitchDirection).rawValue.romanNumeral)"
    }
    
    public func shorthand(for pitchDirection: PitchDirection) -> String {
        if isTritone {
            return "\(pitchDirection.shortHand)tt"
        } else {
            return "\(pitchDirection.shortHand)\(degreeQuality(for: pitchDirection).shortHand)\(degreeQuantity(for: pitchDirection).rawValue)"
        }
    }
        
    public func label(for pitchDirection: PitchDirection) -> String {
        if isTritone {
            return "\(pitchDirection.shortHand) tritone"
        } else {
            return "\(pitchDirection.label) \(majorMinor.label) \(degreeQuantity(for: pitchDirection).label)"
        }
    }

    // private helper functions
        
    public func degreeQuality(for pitchDirection: PitchDirection) -> MajorMinor {
        pitchDirection.isUpward ? self.majorMinor : self.majorMinor.complement
    }
    
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
            case .zero:   // 0
                return .one
            case .one:    // 1
                return .two
            case .two:    // 2
                return .two
            case .three:  // 3
                return .three
            case .four:   // 4
                return .three
            case .five:   // 5
                return .four
            case .six:    // 6
                return .four
            case .seven:  // 7
                return .five
            case .eight:  // 8
                return .six
            case .nine:   // 9
                return .six
            case .ten:    // 10
                return .seven
            case .eleven: // 11
                return .seven
            case .twelve: // 12
                return .eight
            }
        } else {
            switch self {
            case .zero:   // 0
                return .one
            case .ten:    // 10
                return .two
            case .eleven: // 11
                return .two
            case .one:    // 1
                return .seven
            case .two:    // 2
                return .seven
            case .three:  // 3
                return .six
            case .four:   // 4
                return .six
            case .five:   // 5
                return .five
            case .six:    // 6
                return .four
            case .seven:  // 7
                return .four
            case .eight:  // 8
                return .three
            case .nine:   // 9
                return .three
            case .twelve: // 12
                return .eight
            }
        }
    }
    
}
