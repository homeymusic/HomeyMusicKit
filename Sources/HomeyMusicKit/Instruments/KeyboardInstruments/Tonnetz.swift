import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    public init() {
        super.init(instrumentChoice: .tonnetz,
                   defaultRows: 1, minRows: 1, maxRows: 18,
                   defaultCols: 3, minCols: 1, maxCols: 18)
    }
    
    public var colIndices: [Int] {
        Array(-cols ... cols)
    }
    
}
