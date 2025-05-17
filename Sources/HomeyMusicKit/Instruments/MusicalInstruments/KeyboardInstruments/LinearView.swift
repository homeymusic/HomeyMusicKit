import SwiftUI
import MIDIKitCore

struct LinearView: View {
    @Bindable var linear: Linear
    @Bindable public var tonality: Tonality

    public init(_ linear: Linear) {
        self.linear = linear
        self.tonality = linear.tonality
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(linear.rowIndices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(
                        linear.colIndices(
                            forTonic: Int(linear.tonicPitch.midiNote.number),
                            pitchDirection: linear.pitchDirection
                        ),
                        id: \.self
                    ) { col in
                        let linearIndex = Int(col) + 12 * Int(row)
                        if Pitch.isValid(linearIndex) {
                            let pitch = linear.pitch(for: MIDINoteNumber(linearIndex))
                            
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
