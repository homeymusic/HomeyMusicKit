import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    @EnvironmentObject var tonalContext: TonalContext

    var body: some View {
        GeometryReader { geometry in
            let rowIndices = tonnetz.rowIndices
            let colIndices = tonnetz.colIndices(
                forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                pitchDirection: tonalContext.pitchDirection
            )
            let _rowColDims = print("rowIndices", rowIndices, "colIndices", colIndices)
            let cellWidth = geometry.size.width / CGFloat(colIndices.count)
            let cellHeight = geometry.size.height / CGFloat(rowIndices.count)
            let _cellDims = print("cellWidth", cellWidth, "cellHeight", cellHeight)
            HStack(spacing: 0) {
                ForEach(colIndices, id: \.self) { col in
                    VStack(spacing: 0) {
                        ForEach(rowIndices, id: \.self) { row in
                            let pitchOffset: Int = (4 * Int(col)) + (7 * Int(row))
                            
                            let pitchClassMIDI: Int = Int(tonalContext.tonicPitch.midiNote.number) + modulo(pitchOffset, 12)
                            let _print = print("pitchClassMIDI", pitchClassMIDI)
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
                    // Stagger each column horizontally by half the cell width.
                    .offset(y: CGFloat(col) * (cellHeight * -0.5))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
