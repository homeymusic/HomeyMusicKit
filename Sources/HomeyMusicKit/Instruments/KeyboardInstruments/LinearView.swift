import SwiftUI
import MIDIKitCore

struct LinearView: View {
    let linear: Linear

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(linear.rowIndices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(
                        linear.colIndices(
                            forTonic: Int(linear.tonality.tonicPitch.midiNote.number),
                            pitchDirection: linear.tonality.pitchDirection
                        ),
                        id: \.self
                    ) { col in
                        let linearIndex = Int(col) + 12 * Int(row)
                        if Pitch.isValid(linearIndex) {
                            let pitch = linear.tonality.pitch(for: MIDINoteNumber(linearIndex))
                            
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
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }
}
