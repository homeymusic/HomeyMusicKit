import Foundation
import MIDIKitIO

public class Violin: StringInstrument {

    @MainActor
    public init() {
        super.init(instrumentChoice: .violin)
    }
    
    public override var openStringsMIDI: [Int] {[76, 69, 62, 55]}

}
