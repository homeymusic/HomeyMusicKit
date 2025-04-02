import Foundation
import MIDIKitIO

public class Instrument: ObservableObject {
    public let instrumentChoice: InstrumentChoice

    public init(instrumentChoice: InstrumentChoice) {
        self.instrumentChoice = instrumentChoice
    }
}
