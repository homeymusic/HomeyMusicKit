import SwiftUI
import MIDIKitCore

struct TonicPickerView: View {
    let tonicPicker: TonicPicker

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonicPicker.tonicPickerNotes.enumerated()), id: \.offset) { col, note in
                if Pitch.isValid(note) {
                    let pitch = tonicPicker.tonality.pitch(for: MIDINoteNumber(note))
                    PitchCell(
                        pitch: pitch,
                        instrument: tonicPicker,
                        row: row,
                        col: col,
                        cellType: .tonicPicker,
                        namedCoordinateSpace: HomeyMusicKit.tonicPickerSpace
                    )
                    .id(pitch.midiNote.number)
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonicPicker.tonality.tonicPitch)
    }
}
