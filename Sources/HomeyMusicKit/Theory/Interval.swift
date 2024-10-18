import SwiftUI
import MIDIKitCore

@available(macOS 11.0, iOS 13.0, *)
public struct Interval: @unchecked Sendable, Comparable, Equatable {
    
    public var semitone: Int8

    private init(_ semitones: Int8) {
        self.semitone = semitones
    }

    // Properties to drive UI changes
    private static let allIntervals: [Int8: Interval] = Dictionary(uniqueKeysWithValues: (-127...127).map { ($0, Interval($0)) })

    public static func interval(for semitone: Int8) -> Interval {
        guard let interval = allIntervals[semitone] else {
            fatalError("Invalid semitone value: \(semitone)")
        }
        return interval
    }
        
    public var isTonic: Bool {
        intervalClass == .P1
    }
    
    public var isOctave: Bool {
        intervalClass == .P8
    }
    
    public var isTritone: Bool {
        intervalClass == .tt
    }

    public var intervalClass: IntervalClass {
        IntervalClass(semitone: Int(semitone))
    }
    
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        lhs.consonanceDissonance < rhs.consonanceDissonance && lhs.majorMinor < rhs.majorMinor
    }

    @MainActor
    private var upwardAccidental: String {
        TonalContext.shared.pitchDirection == .upward ? "♭" : ""
    }

    @MainActor
    private var downwardAccidental: String {
        TonalContext.shared.pitchDirection == .upward ? "" : "♯"
    }
    
    @MainActor
    public var degree: String {
        let caret: String = "\u{0302}"
        let degree: String = String(degreeClassShorthand)
        let direction: String = TonalContext.shared.pitchDirection.shortHand

        switch intervalClass {
        case .P1:
            return "\(direction)\(degree)\(caret)"
        case .m2:
            return "\(direction)\(upwardAccidental)\(degree)\(caret)"
        case .M2:
            return "\(direction)\(downwardAccidental)\(degree)\(caret)"
        case .m3:
            return "\(direction)\(upwardAccidental)\(degree)\(caret)"
        case .M3:
            return "\(direction)\(downwardAccidental)\(degree)\(caret)"
        case .P4:
            return "\(direction)\(degree)\(caret)"
        case .tt:
            return TonalContext.shared.pitchDirection == .upward ? "\(direction)♭\(degree)\(caret)" : "\(direction)♯\(degree)\(caret)"
        case .P5:
            return "\(direction)\(degree)\(caret)"
        case .m6:
            return "\(direction)\(upwardAccidental)\(degree)\(caret)"
        case .M6:
            return "\(direction)\(downwardAccidental)\(degree)\(caret)"
        case .m7:
            return "\(direction)\(upwardAccidental)\(degree)\(caret)"
        case .M7 :
            return "\(direction)\(downwardAccidental)\(degree)\(caret)"
        case .P8:
            return "\(direction)\(degree)\(caret)"
        }
    }
    
    @MainActor
    public var roman: String {
        let romanNumeral: String = String(degreeClassShorthand.romanNumeral)
        let direction: String = TonalContext.shared.pitchDirection.shortHand

        switch intervalClass {
        case .P1:
            return "\(direction)\(romanNumeral)"
        case .m2:
            return "\(direction)\(upwardAccidental)\(romanNumeral)"
        case .M2:
            return "\(direction)\(downwardAccidental)\(romanNumeral)"
        case .m3:
            return "\(direction)\(upwardAccidental)\(romanNumeral)"
        case .M3:
            return "\(direction)\(downwardAccidental)\(romanNumeral)"
        case .P4:
            return "\(direction)\(romanNumeral)"
        case .tt:
            return TonalContext.shared.pitchDirection == .upward ? "\(direction)♭\(romanNumeral)" : "\(TonalContext.shared.pitchDirection.shortHand)♯\(romanNumeral)"
        case .P5:
            return "\(direction)\(romanNumeral)"
        case .m6:
            return "\(direction)\(upwardAccidental)\(romanNumeral)"
        case .M6:
            return "\(direction)\(downwardAccidental)\(romanNumeral)"
        case .m7:
            return "\(direction)\(upwardAccidental)\(romanNumeral)"
        case .M7 :
            return "\(direction)\(downwardAccidental)\(romanNumeral)"
        case .P8:
            return "\(direction)\(romanNumeral)"
        }
    }
    
    private var degreeShorthand: Int {
        let absModSemitones: Int = abs(Int(semitone) % 12)
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
        return abs(Int(semitone / 12)) * 7 + degree
    }
    
    @MainActor
    private var degreeClassShorthand: Int {
        if semitone == 0 {
            return 1
        } else {
            let modSemitones: Int = modulo(Int(TonalContext.shared.pitchDirection == .upward ? semitone : -semitone), 12)
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
    
    @MainActor
    public var shorthand: String {
        if isTritone {
            return "\(TonalContext.shared.pitchDirection.shortHand)tt"
        } else {
            return "\(TonalContext.shared.pitchDirection.shortHand)\(majorMinor.shortHand)\(degreeShorthand)"
        }
    }

    @MainActor
    public var classShorthand: String {
        if isTritone {
            return "\(TonalContext.shared.pitchDirection.shortHand)tt"
        } else {
            return "\(TonalContext.shared.pitchDirection.shortHand)\(majorMinor.shortHand)\(degreeClassShorthand)"
        }
    }

    public func label(pitchDirection: PitchDirection) -> String {
        if pitchDirection == .downward {
            switch intervalClass {
            case .P1:
                "tonic"
            case .m2:
                "dual minor seventh"
            case .M2:
                "dual major seventh"
            case .m3:
                "dual minor sixth"
            case .M3:
                "dual major sixth"
            case .P4:
                "dual perfect fifth"
            case .tt:
                "tritone"
            case .P5:
                "dual perfect fourth"
            case .m6:
                "dual minor third"
            case .M6:
                "dual major third"
            case .m7:
                "dual minor second"
            case .M7:
                "dual major second"
            case .P8:
                "octave"
            }
        } else {
            switch intervalClass {
            case .P1:
                "tonic"
            case .m2:
                "minor second"
            case .M2:
                "major second"
            case .m3:
                "minor third"
            case .M3:
                "major third"
            case .P4:
                "perfect fourth"
            case .tt:
                "tritone"
            case .P5:
                "perfect fifth"
            case .m6:
                "minor sixth"
            case .M6:
                "major sixth"
            case .m7:
                "minor seventh"
            case .M7:
                "major seventh"
            case .P8:
                "octave"
            }
        }
    }

    public var emoji: Image {
        Image(emojiFileName, bundle: .module)  // Load the image from the package's asset catalog
    }
    
    private var emojiFileName: String {
        switch intervalClass {
        case .P1:
            "home_tortoise_tree"
        case .m2:
            "stone_blue_hare"
        case .M2:
            "stone_gold"
        case .m3:
            "diamond_blue"
        case .M3:
            "diamond_gold_sun"
        case .P4:
            "tent_blue"
        case .tt:
            "disco"
        case .P5:
            "tent_gold"
        case .m6:
            "diamond_blue_rain"
        case .M6:
            "diamond_gold"
        case .m7:
            "stone_blue"
        case .M7:
            "stone_gold_hare"
        case .P8:
            "home"
        }
    }

    public var movableDo: String {
        switch intervalClass {
        case .P1:
            "Do"
        case .m2:
            "Di Ra"
        case .M2:
            "Re"
        case .m3:
            "Ri Me"
        case .M3:
            "Mi"
        case .P4:
            "Fa"
        case .tt:
            "Fi Se"
        case .P5:
            "Sol"
        case .m6:
            "Si Le"
        case .M6:
            "La"
        case .m7:
            "Li Te"
        case .M7:
            "Ti"
        case .P8:
            "Do"
        }
    }    
    
    public var wavelengthRatio: String {
        "λ " + String(decimalToFraction(1/f_ratio))
    }

    public var wavenumberRatio: String {
        "ṽ " + String(decimalToFraction(f_ratio))
    }

    public var periodRatio: String {
        "T " + String(decimalToFraction(1/f_ratio))
    }

    public var frequencyRatio: String {
        "f " + String(decimalToFraction(f_ratio))
    }
    
    private var f_ratio: Double {
//        let ratio = MIDINote.calculateFrequency(midiNote: Int(semitone)) / MIDINote.calculateFrequency(midiNote: 0)
//        
//        return semitone >= 0 ? ratio : 1 / ratio
        MIDINote.calculateFrequency(midiNote: Int(semitone)) / MIDINote.calculateFrequency(midiNote: 0)
    }
    
    public var majorMinor: MajorMinor {
        Interval.majorMinor(intervalClass: intervalClass)
    }
    
    private static func majorMinor(intervalClass: IntervalClass) -> MajorMinor {
        switch intervalClass {
        case .m2, .m3, .m6, .m7: return .minor
        case .P1, .P8, .P4, .P5, .tt: return .neutral
        case .M2, .M3, .M6, .M7: return .major
        }
    }

    // when building UIs we need to know the how notes would behave above and
    // below the MIDI range so that the cells are aranged properly.
    // So we use these static functions to help us.
    public static func majorMinor(_ semitone: Int) -> MajorMinor {
        majorMinor(intervalClass: IntervalClass(semitone: semitone))
    }
    
    public var consonanceDissonance: ConsonanceDissonance {
        switch intervalClass {
        case .P1: return .tonic
        case .P8: return .octave
        case .P4, .P5: return .perfect
        case .m3, .M3, .m6, .M6: return .consonant
        case .m2, .M2, .tt, .m7, .M7: return .dissonant
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

@available(macOS 11.0, iOS 13.0, *)
extension Interval: Identifiable, Hashable  {
    public var id: Int8 {
        return semitone
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
}
