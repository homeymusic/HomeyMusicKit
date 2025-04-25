import SwiftUI
import MIDIKitIO

// Protocol enforcing `openStringsMIDI`
public protocol StringInstrumentProtocol {
    var openStringsMIDI: [Int] { get }
}

// StringInstrument class conforms to protocol
public class StringInstrument: Instrument, StringInstrumentProtocol {
    public var pitchOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]

    public let instrumentChoice: InstrumentChoice

    public var openStringsMIDI: [Int] {
        fatalError("Subclasses must implement openStringsMIDI")
    }
    
    public init(instrumentChoice: InstrumentChoice) {
        self.instrumentChoice = instrumentChoice
    }
    
}
