import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    @Environment(TonalContext.self) var tonalContext
    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalContext.modePickerModes.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    mode: mode,
                    row: row,
                    col: col
                )
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
