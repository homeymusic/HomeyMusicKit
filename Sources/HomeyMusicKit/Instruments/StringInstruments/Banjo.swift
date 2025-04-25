import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Banjo: StringInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.banjo
    public var latching: Bool                     = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Banjo.defaultOpenStringsMIDI

    // — transient UI state (not persisted)
    @Transient public var pitchOverlayCells:      [InstrumentCoordinate: OverlayCell] = [:]
    @Transient public var latchingTouchedPitches: Set<Pitch>                          = []

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [62, 59, 55, 50, 62]

    /// Designated init — you can call `Banjo()` or supply a custom tuning
    public init() {}
}
