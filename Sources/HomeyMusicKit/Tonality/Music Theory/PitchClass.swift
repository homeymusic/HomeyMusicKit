public enum PitchClass: Int, CaseIterable, Identifiable, Equatable {
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
    
    public var id: Int { self.rawValue }

    public static func < (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public init(noteNumber: Int) {
        let moddedValue = modulo(noteNumber, 12)
        self = PitchClass(rawValue: moddedValue)!
    }
    
    public var intValue: Int { self.rawValue }
    
    public var stringValue: String { String(self.rawValue) }
    
    @MainActor
    public func isActivated(in activatedPitches: Set<Pitch>) -> Bool {
        return activatedPitches.contains { $0.pitchClass == self }
    }

    @MainActor
    public func deactivate(in activatedPitches: Set<Pitch>) {
        for pitch in activatedPitches where pitch.pitchClass == self {
            pitch.deactivate()
        }
    }

    // MARK: - Musical Notation Helpers
    
    /// Returns the letter representation (e.g. "C", "C♯", "D♭", etc.) using the provided accidental.
    public func letter(using accidental: Accidental) -> String {
        switch self {
        case .zero:
            return "C"
        case .one:
            return accidental == .sharp ? "C♯" : "D♭"
        case .two:
            return "D"
        case .three:
            return accidental == .sharp ? "D♯" : "E♭"
        case .four:
            return "E"
        case .five:
            return "F"
        case .six:
            return accidental == .sharp ? "F♯" : "G♭"
        case .seven:
            return "G"
        case .eight:
            return accidental == .sharp ? "G♯" : "A♭"
        case .nine:
            return "A"
        case .ten:
            return accidental == .sharp ? "A♯" : "B♭"
        case .eleven:
            return "B"
        }
    }
    
    /// Returns the fixed-do notation (e.g. "Do", "Re♯", etc.) using the provided accidental.
    public func fixedDo(using accidental: Accidental) -> String {
        switch self {
        case .zero:
            return "Do"
        case .one:
            return accidental == .sharp ? "Do♯" : "Re♭"
        case .two:
            return "Re"
        case .three:
            return accidental == .sharp ? "Re♯" : "Mi♭"
        case .four:
            return "Mi"
        case .five:
            return "Fa"
        case .six:
            return accidental == .sharp ? "Fa♯" : "Sol♭"
        case .seven:
            return "Sol"
        case .eight:
            return accidental == .sharp ? "Sol♯" : "La♭"
        case .nine:
            return "La"
        case .ten:
            return accidental == .sharp ? "La♯" : "Si♭"
        case .eleven:
            return "Si"
        }
    }
    

}
