import Foundation
import MIDIKitIO

@MainActor
public class Tonnetz: KeyboardInstrument {
    public convenience init() {
        self.init(instrumentChoice: .tonnetz,
                   phoneRows: (default: 2, min: 1, max: 4),
                   phoneCols: (default: 2, min: 1, max: 5),
                   padRows: (default: 3, min: 1, max: 5),
                   padCols: (default: 4, min: 1, max: 6),
                   computerRows: (default: 3, min: 1, max: 5),   // Customize as needed for macOS
                   computerCols: (default: 4, min: 1, max: 6))   // Customize as needed for macOS
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
