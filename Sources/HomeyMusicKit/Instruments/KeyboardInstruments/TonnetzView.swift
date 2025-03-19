import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    @EnvironmentObject var tonalContext: TonalContext

    var body: some View {
        GeometryReader { geometry in
            let rowIndices = tonnetz.rowIndices
            let colIndices = tonnetz.colIndices
            let cellWidth  = geometry.size.width / CGFloat(colIndices.count)
            
            VStack(spacing: 0) {
                ForEach(rowIndices, id: \.self) { row in
                    let integerOffset = Int(floor(Double(row) / 2.0))
                    let fractionalOffset = Double(row) / 2.0 - Double(integerOffset)
                    HStack(spacing: 0) {
                        ForEach(colIndices.indices, id: \.self) { index in
                            let col = colIndices[index]
                            let isLastCol = (index == colIndices.count - 1)
                            let pitchMIDI: Int = tonalContext.pitchDirection == .upward ?
                            (7 * (Int(col) - integerOffset)) + (4 * Int(row)) :
                            (-7 * (Int(col) - integerOffset)) + (-4 * Int(row))
                            let pitchClassMIDI: Int = Int(tonalContext.tonicPitch.midiNote.number) +
                            (tonalContext.pitchDirection == .upward ? modulo(pitchMIDI, 12) : -modulo(pitchMIDI, 12))
                            
                            Group {
                                if Pitch.isValid(pitchClassMIDI) && !(isLastCol && fractionalOffset != 0.0) {
                                    let pitch = tonalContext.pitch(for: MIDINoteNumber(pitchClassMIDI))
                                    PitchContainerView(pitch: pitch, containerType: .tonnetz)
                                } else {
                                    Color.clear
                                }
                            }
                        }                    }
                    .offset(x: fractionalOffset * cellWidth)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
