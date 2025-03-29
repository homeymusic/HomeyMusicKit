import SwiftUI

public struct TonicKeyboardView: Identifiable, View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    public init() { }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView()
            PitchKeyMultitouchView { touches in
                instrumentalContext.setTonicLocations(
                    tonicLocations: touches,
                    tonalContext: tonalContext
                )
            }
//            instrumentalContext.debugTonicRectOverlay()
        }
        .onPreferenceChange(TonicRectsKey.self) { tonicRectInfos in
            Task { @MainActor in
                instrumentalContext.tonicRectInfos = tonicRectInfos
            }
        }
        .coordinateSpace(name: "TonicPickerSpace")
    }
}
