import SwiftUI
import MIDIKitCore

struct LinearView: View {
    @ObservedObject var linear: Linear
    
    @Environment(TonalContext.self) var tonalContext
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(linear.rowIndices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(
                        linear.colIndices(
                            forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                            pitchDirection: tonalContext.pitchDirection
                        ),
                        id: \.self
                    ) { col in
                        let linearIndex = Int(col) + 12 * Int(row)
                        if Pitch.isValid(linearIndex) {
                            let pitch = tonalContext.pitch(for: MIDINoteNumber(linearIndex))
                            
                            // Directly use PitchView:
                            PitchCell(
                                pitch: pitch,
                                instrument: linear,
                                row: row,
                                col: col
                            )
                            
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
        // This named coordinate space is where PitchView measures itself
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }
}
