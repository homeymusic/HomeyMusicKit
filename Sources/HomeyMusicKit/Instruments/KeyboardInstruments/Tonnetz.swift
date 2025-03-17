import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    @MainActor
    public init() {
        switch HomeyMusicKit.formFactor {
        case .iPhone:
            super.init(instrumentChoice: .tonnetz,
                       defaultRows: 2, minRows: 1, maxRows: 5,
                       defaultCols: 4, minCols: 1, maxCols: 18)
        case .iPad:
            super.init(instrumentChoice: .tonnetz,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        }
    }
    
    public var colIndices: [Int] {
        Array(-cols ... cols)
    }

}
