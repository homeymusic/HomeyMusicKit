import Foundation
import MIDIKitIO

public class Diamanti: KeyboardInstrument {
    @MainActor
    public convenience init() {
        self.init(instrumentChoice: .diamanti,
                   phoneRows: (default: 0, min: 0, max: 2),
                   phoneCols: (default: 13, min: 6, max: 18),
                   padRows: (default: 0, min: 0, max: 2),
                   padCols: (default: 18, min: 6, max: 30),
                   computerRows: (default: 0, min: 0, max: 2),   // Customize as needed
                   computerCols: (default: 18, min: 6, max: 30))  // Customize as needed
    }
    
    // Additional subclass-specific methods…
    public override func fewerCols() {
        if fewerColsAreAvailable {
            let colJump: [Int: Int] = [
                29: 2,
                27: 2,
                25: 3,
                22: 2,
                20: 2,
                17: 2,
                15: 2,
                13: 3,
                10: 2,
                8: 2
            ]
            cols -= colJump[cols] ?? 1
        }
    }
    
    public override func moreCols() {
        if moreColsAreAvailable {
            let colJump: [Int: Int] = [
                6: 2,
                8: 2,
                10: 3,
                13: 2,
                15: 2,
                18: 2,
                20: 2,
                22: 3,
                25: 2,
                27: 2
            ]
            cols += colJump[cols] ?? 1
        }
    }
}
