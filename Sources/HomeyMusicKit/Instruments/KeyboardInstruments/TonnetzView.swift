import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    
    @EnvironmentObject var tonalContext: TonalContext
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(tonnetz.rowIndices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(tonnetz.colIndices(forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                                               pitchDirection: tonalContext.pitchDirection), id: \.self) { col in
                        let pitchMIDI: Int = (7*Int(col) + -4 * Int(row))
                        let pitchClassMIDI: Int = pitchMIDI % 12 + Int(tonalContext.tonicPitch.midiNote.number)
                        Group {
                            if Pitch.isValid(pitchClassMIDI) {
                                let pitch = tonalContext.pitch(for: MIDINoteNumber(pitchClassMIDI))
                                PitchContainerView(
                                    pitch: pitch
                                )
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
            }
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
