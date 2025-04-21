import Foundation
import MIDIKitIO

public class MusicalInstrument: Instrument {
    public let instrumentChoice: InstrumentChoice

    public init(instrumentChoice: InstrumentChoice) {
        self.instrumentChoice = instrumentChoice
    }
}
