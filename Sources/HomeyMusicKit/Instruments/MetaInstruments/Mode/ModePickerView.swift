import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    @Environment(TonalContext.self) var tonalContext
    @ObservedObject var modePicker: ModePicker

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalContext.modePickerModes.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    mode: mode,
                    instrument: modePicker,
                    row: row,
                    col: col
                )
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
