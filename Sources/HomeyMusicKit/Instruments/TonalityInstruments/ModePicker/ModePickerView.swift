import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalityInstrument.modeInts.enumerated()), id: \.offset) { col, mode in
                ModeCell(
                    instrument: tonalityInstrument,
                    mode: mode,
                    row: row,
                    col: col
                )
                .id(mode.rawValue)
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
