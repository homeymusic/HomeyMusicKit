import Foundation
import MIDIKitIO
import UIKit

@MainActor
public class Tonnetz: KeyboardInstrument {
    public init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            super.init(instrumentChoice: .tonnetz,
                       defaultRows: 2, minRows: 1, maxRows: 4,
                       defaultCols: 3, minCols: 1, maxCols: 5)
        case .pad:
            super.init(instrumentChoice: .tonnetz,
                       defaultRows: 3, minRows: 1, maxRows: 5,
                       defaultCols: 4, minCols: 1, maxCols: 6)
        default:
            fatalError("unsupported device idiom")
        }
    }
    
    public var colIndices: [Int] {
        Array(-cols ... cols)
    }
        
    public func noteNumber(row: Int, col: Int, offset: Int, tonalContext: TonalContext) -> Int {
        tonalContext.pitchDirection == .upward ?
        (7 * (col - offset)) + (4 * row) :
        (-7 * (col - offset)) + (-4 * row)
    }
    
    public func pitchClassMIDI(noteNumber: Int, tonalContext: TonalContext) -> Int {
        Int(tonalContext.tonicPitch.midiNote.number) +
        (tonalContext.pitchDirection == .upward ? modulo(noteNumber, 12) : -modulo(noteNumber, 12))
    }
    
}
