import SwiftUI

public struct ModeInstrumentView: Identifiable, View {
    let tonicPicker: TonicPicker
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    
    public init(tonicPicker: TonicPicker) {
        self.tonicPicker = tonicPicker
    }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            ModePickerView(tonicPicker: tonicPicker)
            MultiTouchOverlayView { touches in
                instrumentalContext.setModeLocations(
                    modeLocations: touches,
                    tonalContext: tonalContext
                )
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { overlayCellKey in
            Task { @MainActor in
                instrumentalContext.modeOverlayCells = overlayCellKey
            }
        }
        .coordinateSpace(name: HomeyMusicKit.modePickerSpace)
    }
}
