import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    @MainActor
    public init() {
        switch HomeyMusicKit.formFactor {
        case .iPhone:
            super.init(instrumentType: .tonnetz,
                       defaultRows: 2, minRows: 0, maxRows: 6,
                       defaultCols: 1, minCols: 0, maxCols: 18)
        case .iPad:
            super.init(instrumentType: .tonnetz,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        }
    }
    
    public func colIndices() -> [Int] {
        let tritoneSemitones = 6
        let colsBelow = tritoneSemitones - cols
        let colsAbove = tritoneSemitones + cols
        return Array(colsBelow...colsAbove)
    }

    
}
