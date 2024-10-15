import SwiftUICore

@available(macOS 11.0, iOS 13.0, *)
public struct Interval: Comparable, Equatable {
    public var pitch: Pitch
    public var tonicPitch: Pitch
    public var semitones: Int8
    public var intervalClass: IntegerNotation
    public var pitchDirection: PitchDirection
    
    public init(pitch: Pitch, tonicPitch: Pitch) {
        let semitones = pitch.midi - tonicPitch.midi
        self.pitch = pitch
        self.tonicPitch = tonicPitch
        self.semitones = semitones
        self.intervalClass = IntegerNotation(rawValue: Int8(modulo(Int(self.semitones), 12)))!
        self.pitchDirection = switch semitones {
        case let x where x < 0: .downward
        case let x where x > 0: .upward
        default: .both
        }
    }
    
    public var isTonic: Bool {
        self.pitch == self.tonicPitch
    }
    
    public var isTonicOrOctave: Bool {
        self.intervalClass == .zero
    }
    
    public var majorMinor: MajorMinor {
        Interval.majorMinor(midi: Int(pitch.midi), tonicMIDI: Int(tonicPitch.midi))
    }
    
    public var wavelengthRatio: String {
        "λ " + String(decimalToFraction(Double(pitch.wavelength) / Double(tonicPitch.wavelength)))
    }

    public var wavenumberRatio: String {
        "ṽ " + String(decimalToFraction(Double(pitch.wavenumber) / Double(tonicPitch.wavenumber)))
    }

    public var periodRatio: String {
        "T " + String(decimalToFraction(Double(pitch.period) / Double(tonicPitch.period)))
    }

    public var frequencyRatio: String {
        "f " + String(decimalToFraction(Double(pitch.frequency) / Double(tonicPitch.frequency)))
    }
    
    public static func majorMinor(midi: Int, tonicMIDI: Int) -> MajorMinor {
        let intervalClass = IntegerNotation(rawValue: Int8(modulo(Int(midi - tonicMIDI), 12)))!

        switch intervalClass {
        case .one, .three, .eight, .ten: return .minor
        case .zero, .five, .six, .seven: return .neutral
        case .two, .four, .nine, .eleven: return .major
        }
    }
    
    public static func intervalClass(midi: Int, tonicMIDI: Int) -> IntegerNotation {
        return IntegerNotation(rawValue: Int8(modulo(midi - tonicMIDI, 12)))!
    }
    
    public var consonanceDissonance: ConsonanceDissonance {
        if pitch == tonicPitch {
            return .tonic
        } else {
            switch intervalClass {
            case .zero: return .octave
            case .five, .seven: return .perfect
            case .three, .four, .eight, .nine: return .consonant
            case .one, .two, .six, .ten, .eleven: return .dissonant
            }
        }
    }
       
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        lhs.consonanceDissonance < rhs.consonanceDissonance && lhs.majorMinor < rhs.majorMinor
    }
     
    @MainActor
    public var degree: String {
        let caret = "\u{0302}"
        let degree = degreeClassShorthand
        let direction = TonalContext.shared.pitchDirection.shortHand
        let accidental: String = TonalContext.shared.pitchDirection == .upward ? "♭" : "♯"
        
        switch intervalClass {
        case .zero:
            return "\(direction)\(degree)\(caret)"
        case .one:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(degree)\(caret)"
        case .two:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(degree)\(caret)"
        case .three:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(degree)\(caret)"
        case .four:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(degree)\(caret)"
        case .five:
            return "\(direction)\(degree)\(caret)"
        case .six:
            return TonalContext.shared.pitchDirection == .upward ? "\(direction)♭\(degree)\(caret)" : "\(direction)♯\(degree)\(caret)"
        case .seven:
            return "\(direction)\(degree)\(caret)"
        case .eight:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(degree)\(caret)"
        case .nine:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(degree)\(caret)"
        case .ten:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(degree)\(caret)"
        case .eleven :
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(degree)\(caret)"
        }
    }
    
    @MainActor
    public var roman: String {
        let romanNumeral = degreeClassShorthand.romanNumeral
        let accidental: String = TonalContext.shared.pitchDirection == .upward ? "♭" : "♯"
        let direction = TonalContext.shared.pitchDirection.shortHand

        switch intervalClass {
        case .zero:
            return "\(direction)\(romanNumeral)"
        case .one:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(romanNumeral)"
        case .two:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(romanNumeral)"
        case .three:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(romanNumeral)"
        case .four:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(romanNumeral)"
        case .five:
            return "\(direction)\(romanNumeral)"
        case .six:
            return TonalContext.shared.pitchDirection == .upward ? "\(direction)♭\(romanNumeral)" : "\(pitchDirection.shortHand)♯\(romanNumeral)"
        case .seven:
            return "\(direction)\(romanNumeral)"
        case .eight:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(romanNumeral)"
        case .nine:
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(romanNumeral)"
        case .ten:
            return "\(direction)\(TonalContext.shared.pitchDirection == .upward ? accidental : "")\(romanNumeral)"
        case .eleven :
            return "\(direction)\(TonalContext.shared.pitchDirection == .downward ? accidental : "")\(romanNumeral)"
        }
    }
    
    public var octave: Int {
        Int(semitones / 12)
    }
    
    public var degreeShorthand: Int {
        let absModSemitones: Int = abs(Int(semitones) % 12)
        let degree: Int = switch absModSemitones {
        case 0:  1
        case 1:  2
        case 4:  3
        case 5:  4
        case 6:  5
        case 7:  5
        case 8:  6
        case 9:  6
        case 10: 7
        case 11: 7
        case 12: 8
        default: absModSemitones
        }
        return abs(octave) * 7 + degree
    }
    
    @MainActor
    public var degreeClassShorthand: Int {
        if semitones == 0 {
            return 1
        } else {
            let modSemitones: Int = modulo(Int(TonalContext.shared.pitchDirection == .upward ? semitones : -semitones), 12)
            return switch modSemitones {
            case 0:  8
            case 1:  2
            case 4:  3
            case 5:  4
            case 6:  5
            case 7:  5
            case 8:  6
            case 9:  6
            case 10: 7
            case 11: 7
            default: modSemitones
            }
        }
    }
    
    public var tritone: Bool {
        abs(modulo(Int(semitones), 12)) == 6
    }
    
    public var shorthand: String {
        if tritone {
            return "\(pitchDirection.shortHand)tt"
        } else {
            return "\(pitchDirection.shortHand)\(majorMinor.shortHand)\(degreeShorthand)"
        }
    }

    @MainActor
    public var classShorthand: String {
        if tritone {
            return "\(TonalContext.shared.pitchDirection.shortHand)tt"
        } else {
            return "\(TonalContext.shared.pitchDirection.shortHand)\(majorMinor.shortHand)\(degreeClassShorthand)"
        }
    }

    public var label: String {
        if pitch == tonicPitch {
            return "unison"
        } else {
            return switch intervalClass {
            case .zero:
                "octave"
            case .one:
                "minor second"
            case .two:
                "major second"
            case .three:
                "minor third"
            case .four:
                "major third"
            case .five:
                "perfect fourth"
            case .six:
                "tritone"
            case .seven:
                "perfect fifth"
            case .eight:
                "minor sixth"
            case .nine:
                "major sixth"
            case .ten:
                "minor seventh"
            case .eleven:
                "major seventh"
            }
        }
    }

    public var emoji: Image {
        return Image(emojiFileName, bundle: .module)  // Load the image from the package's asset catalog
    }
    
    public var emojiFileName: String {
        if pitch == tonicPitch {
            return "home_tortoise_tree"
        } else {
            return switch intervalClass {
            case .zero:
                "home"
            case .one:
                "stone_blue_hare"
            case .two:
                "stone_gold"
            case .three:
                "diamond_blue"
            case .four:
                "diamond_gold_sun"
            case .five:
                "tent_blue"
            case .six:
                "disco"
            case .seven:
                "tent_gold"
            case .eight:
                "diamond_blue_rain"
            case .nine:
                "diamond_gold"
            case .ten:
                "stone_blue"
            case .eleven:
                "stone_gold_hare"
            }
        }

    }

    public var movableDo: String {
        switch intervalClass {
        case .zero:
            "Do"
        case .one:
            "Di Ra"
        case .two:
            "Re"
        case .three:
            "Ri Me"
        case .four:
            "Mi"
        case .five:
            "Fa"
        case .six:
            "Fi Se"
        case .seven:
            "Sol"
        case .eight:
            "Si Le"
        case .nine:
            "La"
        case .ten:
            "Li Te"
        case .eleven:
            "Ti"
        }
    }

}

extension Int {
    public var romanNumeral: String {
        var integerValue = self
        // Roman numerals cannot be represented in integers greater than 3999
        if self >= 4000 {
            return "Invalid input (greater than 3999)"
        }
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"), (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        for i in mappingList {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
}


public enum IntervalClass: Int8, CaseIterable, Identifiable, Comparable, Equatable {
    case P1 = 0
    case P8 = 12
    case P5 = 7
    case P4 = 5
    case M3 = 4
    case m6 = 8
    case M6 = 9
    case m3 = 3
    case tt = 6
    case M2 = 2
    case m7 = 10
    case M7 = 11
    case m2 = 1

    public var id: Int8 { self.rawValue }

    public static func < (lhs: IntervalClass, rhs: IntervalClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    @available(macOS 11.0, iOS 13.0, *)
    public var interval: Interval {
        Interval(pitch: Pitch(self.rawValue), tonicPitch: Pitch(0) )
    }
    
}


@available(macOS 11.0, iOS 13.0, *)
extension Interval: Identifiable, Hashable  {
    public var id: Int8 {
        return self.pitch.midi
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
}
