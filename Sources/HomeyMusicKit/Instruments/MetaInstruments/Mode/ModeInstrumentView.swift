import SwiftUI

public struct ModeInstrumentView: Identifiable, View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext
    
    public init() { }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            ModePickerView()            
            MultiTouchOverlayView { touches in
                instrumentalContext.setModeLocations(
                    modeLocations: touches,
                    tonalContext: tonalContext,
                    notationalTonicContext: notationalTonicContext
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
