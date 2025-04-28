import SwiftUI

public struct TonicInstrumentView: Identifiable, View {
    let tonicPicker: TonicPicker
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    
    public init(tonicPicker: TonicPicker) {
        self.tonicPicker = tonicPicker
    }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView(tonicPicker: tonicPicker)
            MultiTouchOverlayView { touches in
                instrumentalContext.setTonicLocations(
                    tonicLocations: touches,
                    tonicPicker: tonicPicker
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
