import SwiftUI

public final class PitchClass: ObservableObject, Identifiable {
    public let value: Int
    public var id: Int { value }

    @Published private var activatedPitchesCount: Int = 0  // ✅ Tracks active pitches

    // ✅ Computed property: Determines if any pitches in this PitchClass are active
    public var isActivated: Bool {
        activatedPitchesCount > 0
    }

    public init(value: Int) {
        precondition((0...11).contains(value), "PitchClass value must be between 0 and 11")
        self.value = value
    }
    
    // ✅ Initialize from a MIDI note number
    public init(noteNumber: Int) {
        let moddedValue = noteNumber % 12
        self.value = moddedValue
    }

    // ✅ Returns an integer representation of this PitchClass
    public var intValue: Int { value }

    // ✅ Returns a string representation of the PitchClass (e.g., "0", "1", ... "11")
    public var stringValue: String { String(value) }

    // ✅ Track activation safely
    public func incrementActivatedPitches() {
        activatedPitchesCount += 1
        print("class:", self.intValue, "incrementActivatedPitches activatedPitchesCount", activatedPitchesCount)
    }

    public func decrementActivatedPitches() {
        activatedPitchesCount = max(0, activatedPitchesCount - 1)  // Prevent negative values
        print("class:", self.intValue, "decrementActivatedPitches activatedPitchesCount", activatedPitchesCount)
    }

    // ✅ Compare two PitchClasses (to maintain the `Comparable` feature)
    public static func < (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.value < rhs.value
    }

    // ✅ Equality check
    public static func == (lhs: PitchClass, rhs: PitchClass) -> Bool {
        return lhs.value == rhs.value
    }

    public func letter(using accidental: Accidental) -> String {
        switch intValue {
        case 0:
            return "C"
        case 1:
            return accidental == .sharp ? "C♯" : "D♭"
        case 2:
            return "D"
        case 3:
            return accidental == .sharp ? "D♯" : "E♭"
        case 4:
            return "E"
        case 5:
            return "F"
        case 6:
            return accidental == .sharp ? "F♯" : "G♭"
        case 7:
            return "G"
        case 8:
            return accidental == .sharp ? "G♯" : "A♭"
        case 9:
            return "A"
        case 10:
            return accidental == .sharp ? "A♯" : "B♭"
        case 11:
            return "B"
        default:
            return ""
        }
    }
    
    /// Returns the fixed-do notation (e.g. "Do", "Re♯", etc.) using the provided accidental.
    public func fixedDo(using accidental: Accidental) -> String {
        switch intValue {
        case 0:
            return "Do"
        case 1:
            return accidental == .sharp ? "Do♯" : "Re♭"
        case 2:
            return "Re"
        case 3:
            return accidental == .sharp ? "Re♯" : "Mi♭"
        case 4:
            return "Mi"
        case 5:
            return "Fa"
        case 6:
            return accidental == .sharp ? "Fa♯" : "Sol♭"
        case 7:
            return "Sol"
        case 8:
            return accidental == .sharp ? "Sol♯" : "La♭"
        case 9:
            return "La"
        case 10:
            return accidental == .sharp ? "La♯" : "Si♭"
        case 11:
            return "Si"
        default:
            return ""
        }
    }
    

}
