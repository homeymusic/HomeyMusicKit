import Foundation
import MIDIKitIO

public class Tonnetz: KeyboardInstrument {
    public init() {
        super.init(instrumentChoice: .tonnetz,
                   defaultRows: 2, minRows: 1, maxRows: 18,
                   defaultCols: 3, minCols: 1, maxCols: 18)
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
