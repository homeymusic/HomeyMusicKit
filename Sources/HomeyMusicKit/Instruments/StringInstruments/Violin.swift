import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Violin: StringInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.violin
    public var latching: Bool                     = false
    public var showOutlines: Bool               = true

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Violin.defaultOpenStringsMIDI

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [76, 69, 62, 55]

    /// Designated init — you can call `Violin()` or supply a custom tuning
    public init() {}
}
