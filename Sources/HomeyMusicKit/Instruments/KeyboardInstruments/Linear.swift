import Foundation
import MIDIKitIO
import UIKit

public class Linear: KeyboardInstrument {
    @MainActor
    public init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            super.init(instrumentChoice: .linear,
                       defaultRows: 0, minRows: 0, maxRows: 5,
                       defaultCols: 9, minCols: 6, maxCols: 18)
        case .pad:
            super.init(instrumentChoice: .linear,
                       defaultRows: 0, minRows: 0, maxRows: 2,
                       defaultCols: 13, minCols: 6, maxCols: 18)
        default:
            fatalError("unsupported device idiom")
        }
    }
    
}
