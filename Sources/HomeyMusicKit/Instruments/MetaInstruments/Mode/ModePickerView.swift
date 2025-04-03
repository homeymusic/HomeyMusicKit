import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    @Environment(TonalContext.self) var tonalContext
    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalContext.modePickerModes.enumerated()), id: \.offset) { col, mode in
                let mode = mode
                ModeContainerView(
                    mode: mode,
                    columnIndex: col,
                    row: row,
                    col: col
                )
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
