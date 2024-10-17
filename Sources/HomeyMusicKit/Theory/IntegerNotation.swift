import MIDIKitCore

public enum IntegerNotation: UInt7, CaseIterable, Identifiable, Equatable {
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
    
    public var id: UInt7 { self.rawValue }

    public var intValue: Int { Int(self.rawValue) }
    
    public var stringValue: String {String(self.rawValue)}
}
