import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    @MainActor
    public init() {
        switch HomeyMusicKit.formFactor {
        case .iPhone:
            super.init(instrumentType: .tonnetz,
                       defaultRows: 1, minRows: 0, maxRows: 5,
                       defaultCols: 8, minCols: 6, maxCols: 18)
        case .iPad:
            super.init(instrumentType: .tonnetz,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        }
    }
    
    public override func colIndices(forTonic tonic: Int, pitchDirection: PitchDirection) -> [Int] {
        let tritoneSemitones = 6
        let colsBelow = tritoneSemitones - cols
        let colsAbove = tritoneSemitones + cols
        return Array(colsBelow...colsAbove)
    }

    
}
