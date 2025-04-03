import SwiftUI

public struct TonicInstrumentView: Identifiable, View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    @Environment(NotationalTonicContext.self) var notationalTonalContext
    
    public init() { }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView()
            MultiTouchOverlayView { touches in
                instrumentalContext.setTonicLocations(
                    tonicLocations: touches,
                    tonalContext: tonalContext,
                    notationalTonicContext: notationalTonalContext
                )
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { overlayCellKey in
            Task { @MainActor in
                instrumentalContext.tonicOverlayCells = overlayCellKey
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
    }
}
