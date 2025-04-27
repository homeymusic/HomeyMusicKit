import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    let tonicPicker: TonicPicker

    @Environment(TonalContext.self) var tonalContext
    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalContext.modePickerModes.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    tonicPicker: tonicPicker,
                    mode: mode,
                    row: row,
                    col: col,
                    instrument: tonicPicker
                )
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
