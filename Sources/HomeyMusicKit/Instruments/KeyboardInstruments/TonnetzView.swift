import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    @EnvironmentObject var tonalContext: TonalContext

    var body: some View {
        GeometryReader { geometry in
            let rowIndices = tonnetz.rowIndices
            let colIndices = tonnetz.colIndices
            let cellWidth = geometry.size.width / CGFloat(colIndices.count)
            let cellHeight = geometry.size.height / CGFloat(rowIndices.count)
            
            VStack(spacing: 0) {
                ForEach(rowIndices, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(colIndices, id: \.self) { col in
                            let pitchMIDI: Int = (7 * Int(col)) + (4 * Int(row))
                            let pitchClassMIDI: Int = modulo(pitchMIDI, 12) + Int(tonalContext.tonicPitch.midiNote.number)
                            Group {
                                if Pitch.isValid(pitchClassMIDI) {
                                    let pitch = tonalContext.pitch(for: MIDINoteNumber(pitchClassMIDI))
                                    PitchContainerView(pitch: pitch)
                                        .frame(width: cellWidth, height: cellHeight)
                                } else {
                                    Color.clear
                                        .frame(width: cellWidth, height: cellHeight)
                                }
                            }
                        }
                    }
                    .offset(x: CGFloat(row) * (cellWidth * 0.5))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
