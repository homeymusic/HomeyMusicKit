import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    let tonicPicker: TonicPicker

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonicPicker.modePickerModes.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    tonicPicker: tonicPicker,
                    mode: mode,
                    row: row,
                    col: col,
                    instrument: tonicPicker
                )
                .id(mode.rawValue)
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
