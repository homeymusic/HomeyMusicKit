import Foundation
import MIDIKitIO

public class Guitar: StringInstrument {
    
    public init() {
        super.init(instrumentChoice: .guitar)
    }
    
    public override var openStringsMIDI: [Int] {[64, 59, 55, 50, 45, 40]}
}
