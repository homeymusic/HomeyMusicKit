import SwiftUI
import MIDIKitCore

struct TonicPickerView: View {
    @Environment(TonalContext.self) var tonalContext
    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalContext.tonicPickerNotes.enumerated()), id: \.offset) { col, note in
                if Pitch.isValid(note) {
                    let pitch = tonalContext.pitch(for: MIDINoteNumber(note))
                    PitchCell(
                        pitch: pitch,
                        instrument: TonicPicker(),
                        row: row,
                        col: col,
                        cellType: .tonicPicker,
                        namedCoordinateSpace: HomeyMusicKit.tonicPickerSpace
                    )
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicPitch)
    }
}
