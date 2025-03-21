import Foundation
import MIDIKitIO
import UIKit

public class Diamanti: KeyboardInstrument {
    @MainActor
    public init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            super.init(instrumentChoice: .diamanti,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        case .pad:
            super.init(instrumentChoice: .diamanti,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 18, minCols: 6, maxCols: 30)
        default:
            fatalError("unsupported device idiom")
        }
    }
    
    public override func fewerCols() {
        if fewerColsAreAvailable {
            let colJump: [Int:Int] = [
                29:2,
                27:2,
                25:3,
                22:2,
                20:2,
                17:2,
                15:2,
                13:3,
                10:2,
                8:2
            ]
            cols -= colJump[cols] ?? 1
        }
    }
    
    public override func moreCols() {
        if moreColsAreAvailable {
            let colJump: [Int:Int] = [
                6:2,
                8:2,
                10:3,
                13:2,
                15:2,
                18:2,
                20:2,
                22:3,
                25:2,
                27:2
            ]
            cols += colJump[cols] ?? 1
        }
    }

}
