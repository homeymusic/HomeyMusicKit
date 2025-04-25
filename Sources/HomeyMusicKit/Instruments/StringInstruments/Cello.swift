import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Cello: StringInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.cello
    public var latching: Bool                     = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int]

    // — transient UI state (not persisted)
    @Transient public var pitchOverlayCells:      [InstrumentCoordinate: OverlayCell] = [:]
    @Transient public var latchingTouchedPitches: Set<Pitch>                          = []

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [57, 50, 43, 36]

    /// Designated init — you can call `Cello()` or supply a custom tuning
    public init(openStringsMIDI: [Int] = defaultOpenStringsMIDI) {
        self.openStringsMIDI = openStringsMIDI
    }
}
