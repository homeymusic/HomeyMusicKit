public enum IntervalClass: UInt8, CaseIterable, Identifiable, Comparable, Equatable {
    case P1 = 0
    case m2 = 1
    case M2 = 2
    case m3 = 3
    case M3 = 4
    case P4 = 5
    case tt = 6
    case P5 = 7
    case m6 = 8
    case M6 = 9
    case m7 = 10
    case M7 = 11
    case P8 = 12

    public var id: UInt8 { self.rawValue }

    public static func < (lhs: IntervalClass, rhs: IntervalClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    // Custom initializer using semitone value, with special handling for 0
    public init(semitone: Int) {
        if semitone == 0 {
            // If semitone is exactly 0, map to P1 (unison)
            self = .P1
        } else {
            // Modulo operation to handle wrapping
            let moddedSemitone = UInt8(modulo(Int(semitone), 12))
            // If modulo result is 0, map to P8 (octave), otherwise use the raw value
            if moddedSemitone == 0 {
                self = .P8
            } else if let intervalClass = IntervalClass(rawValue: moddedSemitone) {
                self = intervalClass
            } else {
                fatalError("Invalid semitone value: \(semitone)")
            }
        }
    }

    // Helper function to get the corresponding Interval object
    private func toInterval() -> Interval {
        return Interval.interval(for: Int8(self.rawValue))
    }

    // Now use the Interval object to access dynamic properties
    public var consonanceDissonance: ConsonanceDissonance {
        toInterval().consonanceDissonance
    }

    public var majorMinor: MajorMinor {
        toInterval().majorMinor
    }

    @MainActor
    public var shorthand: String {
        toInterval().shorthand
    }

    public var label: String {
        toInterval().label(pitchDirection: .upward) // Assuming default is upward
    }

}
