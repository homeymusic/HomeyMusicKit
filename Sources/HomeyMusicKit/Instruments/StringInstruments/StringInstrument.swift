import SwiftUI
import MIDIKitIO

// Protocol enforcing `openStringsMIDI`
public protocol StringInstrumentProtocol {
    var openStringsMIDI: [Int] { get }
}

// StringInstrument class conforms to protocol
public class StringInstrument: MusicalInstrument, StringInstrumentProtocol {
    public var openStringsMIDI: [Int] {
        fatalError("Subclasses must implement openStringsMIDI")
    }
}
