import SwiftUI
import MIDIKitCore

struct ModePickerView: View {
    @EnvironmentObject var tonalContext: TonalContext
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tonalContext.modePickerModes.indices, id: \.self) { index in
                let mode = tonalContext.modePickerModes[index]
                ModeContainerView(
                    mode: mode,
                    columnIndex: index
                )
            }
        }
        .coordinateSpace(name: "ModePickerSpace")
        .clipShape(Rectangle())
    }
}
