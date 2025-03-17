import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    @MainActor
    public init() {
        switch HomeyMusicKit.formFactor {
        case .iPhone:
            super.init(instrumentChoice: .tonnetz,
                       defaultRows: 1, minRows: 0, maxRows: 5,
                       defaultCols: 8, minCols: 6, maxCols: 18)
        case .iPad:
            super.init(instrumentChoice: .tonnetz,
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
