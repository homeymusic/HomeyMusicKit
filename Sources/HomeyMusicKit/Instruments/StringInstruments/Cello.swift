import Foundation
import MIDIKitIO

public class Cello: StringInstrument {

    @MainActor
    public init() {
        super.init(instrumentChoice: .cello)
    }

    public override var openStringsMIDI: [Int] { [57, 50, 43, 36] }

}
