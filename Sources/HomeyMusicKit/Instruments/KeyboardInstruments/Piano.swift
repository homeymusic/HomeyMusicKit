import Foundation
import MIDIKitIO

public class Piano: KeyboardInstrument {
    @MainActor
    public convenience init() {
        self.init(instrumentChoice: .piano,
                   phoneRows: (default: 0, min: 0, max: 2),
                   phoneCols: (default: 8, min: 4, max: 11),
                   padRows: (default: 0, min: 0, max: 2),
                   padCols: (default: 11, min: 4, max: 18),
                   computerRows: (default: 0, min: 0, max: 2),  // Customize if needed
                   computerCols: (default: 11, min: 4, max: 18)) // Customize if needed
    }
    
    public override func colIndices(forTonic tonic: Int, pitchDirection: PitchDirection) -> [Int] {
        let tritoneSemitones = pitchDirection == .downward ? -6 : 6
        let tritoneMIDI = Int(tonic) + tritoneSemitones
        
        let naturalsPerSide = cols
        
        // If there are no natural notes on either side, return the tritone MIDI note.
        guard naturalsPerSide > 0 else { return [tritoneMIDI] }
        
        // Determine the natural note below the tritone.
        var lowerCount = 0
        var lowerBound = tritoneMIDI
        var candidate = tritoneMIDI - 1
        while lowerCount < naturalsPerSide {
            if Pitch.isNatural(candidate) {
                lowerBound = candidate
                lowerCount += 1
            }
            candidate -= 1
        }
        
        // Determine the natural note above the tritone.
        var upperCount = 0
        var upperBound = tritoneMIDI
        candidate = tritoneMIDI + 1
        while upperCount < naturalsPerSide {
            if Pitch.isNatural(candidate) {
                upperBound = candidate
                upperCount += 1
            }
            candidate += 1
        }
        
        // Return all MIDI note numbers between the two natural notes.
        return Array(lowerBound...upperBound)
    }
}
