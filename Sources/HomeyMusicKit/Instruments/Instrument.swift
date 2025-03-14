import Foundation
import MIDIKitIO

public class Instrument: ObservableObject {
    public let instrumentType: InstrumentChoice

    public init(instrumentType: InstrumentChoice) {
        self.instrumentType = instrumentType
    }
    
    // TODO: put all the notational settings in here?
    // current thinking? No. In fact, maybe it is better
    // if (like accidental choice) any chaoice about metadata
    // applies to all the instrumnts.
    // then create an InstrumentsDefaultsManager for it?
    // and move it all into HomeyMusicKit?
    // and accidental setting probably goes in here?
}
