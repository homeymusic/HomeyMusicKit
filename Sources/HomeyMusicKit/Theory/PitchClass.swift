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

    // Custom initializer using a pitch note number, modded by 12
    public init(noteNumber: Int) {
        let moddedValue = modulo(noteNumber, 12)  // Use the modulo function from your util file
        guard let pitchClass = PitchClass(rawValue: moddedValue) else {
            fatalError("Invalid pitch class value: \(noteNumber)")
        }
        self = pitchClass
    }

    public var intValue: Int { self.rawValue }
    
    public var stringValue: String { String(self.rawValue) }
    
    // Computed property to check if any pitch in this pitch class is activated
    public var isActivated: Bool {
        return Pitch.activatedPitches.contains { $0.pitchClass == self }
    }

}
