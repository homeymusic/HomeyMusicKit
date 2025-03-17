import Foundation
import MIDIKitIO

public class Bass: StringInstrument {
    
    public init() {
        super.init(instrumentChoice: .bass)
    }
    
    public override var openStringsMIDI: [Int] { [43, 38, 33, 28] }
}
