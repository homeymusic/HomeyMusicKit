import Foundation
import MIDIKitIO

public class Violin: StringInstrument {
    
    public init() {
        super.init(instrumentChoice: .violin)
    }
    
    public override var openStringsMIDI: [Int] {[76, 69, 62, 55]}

}
