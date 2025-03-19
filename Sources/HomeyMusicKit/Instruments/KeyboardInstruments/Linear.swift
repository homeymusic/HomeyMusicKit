import Foundation
import MIDIKitIO

public class Linear: KeyboardInstrument {
    @MainActor
    public init() {
        switch HomeyMusicKit.formFactor {
        case .iPhone:
            super.init(instrumentChoice: .linear,
                       defaultRows: 0, minRows: 0, maxRows: 5,
                       defaultCols: 9, minCols: 6, maxCols: 18)
        case .iPad:
            super.init(instrumentChoice: .linear,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        }
    }
    
}
