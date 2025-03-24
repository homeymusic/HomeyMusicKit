import Foundation
import MIDIKitIO

public class Linear: KeyboardInstrument {
    @MainActor
    public convenience init() {
        self.init(instrumentChoice: .linear,
                  phoneRows: (default: 0, min: 0, max: 5),
                  phoneCols: (default: 9, min: 6, max: 18),
                  padRows: (default: 0, min: 0, max: 5),
                  padCols: (default: 13, min: 6, max: 18),
                  computerRows: (default: 0, min: 0, max: 5),    // Customize if needed
                  computerCols: (default: 13, min: 6, max: 18))   // Customize if needed
    }
}
