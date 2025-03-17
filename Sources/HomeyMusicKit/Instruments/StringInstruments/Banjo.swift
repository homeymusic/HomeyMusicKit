import Foundation
import MIDIKitIO

public class Banjo: StringInstrument {
    
    public init() {
        super.init(instrumentChoice: .banjo)
    }
    
    public override var openStringsMIDI: [Int] { [62, 59, 55, 50, 62] }
}
