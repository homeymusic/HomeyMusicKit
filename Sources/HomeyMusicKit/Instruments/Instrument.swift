import Foundation
import MIDIKitIO

@Observable
public class Instrument {
    public let instrumentChoice: InstrumentChoice

    public init(instrumentChoice: InstrumentChoice) {
        self.instrumentChoice = instrumentChoice
    }
}
