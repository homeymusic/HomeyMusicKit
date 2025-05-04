import SwiftUI
import MIDIKitCore

struct TonicaView: View {
    let tonica: Tonica

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonica.midiNoteInts.enumerated()), id: \.offset) { col, noteInt in
                if Pitch.isValid(noteInt) {
                    let pitch = tonica.tonality.pitch(for: MIDINoteNumber(noteInt))
                    PitchCell(
                        pitch: pitch,
                        instrument: tonica,
                        row: row,
                        col: col,
                        cellType: .tonicPicker,
                        namedCoordinateSpace: HomeyMusicKit.tonicaSpace
                    )
                    .id(pitch.midiNote.number)
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicaSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonica.tonality.tonicPitch)
    }
}
