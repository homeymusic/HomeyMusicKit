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
    public var isActivated: Bool {
        return TonalContext.shared.activatedPitches.contains { $0.pitchClass == self }
    }

}
