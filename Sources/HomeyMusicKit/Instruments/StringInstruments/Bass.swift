import Foundation
import SwiftData
import MIDIKitIO

@Model
public final class Bass: StringInstrument {
    // — persisted Instrument state
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.bass
    public var latching: Bool                     = false

    // — persisted StringInstrument state
    public var openStringsMIDI: [Int] = Bass.defaultOpenStringsMIDI

    // — transient UI state (not persisted)
    @Transient public var pitchOverlayCells:      [InstrumentCoordinate: OverlayCell] = [:]
    @Transient public var latchingTouchedPitches: Set<Pitch>                          = []

    // — config constants (in-memory only)
    public static let defaultOpenStringsMIDI: [Int] = [43, 38, 33, 28]

    /// Designated init — you can call `Bass()` or supply a custom tuning
    public init() {}
}
