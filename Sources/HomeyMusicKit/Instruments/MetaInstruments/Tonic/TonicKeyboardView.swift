import SwiftUI

public struct TonicKeyboardView: Identifiable, View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    @Environment(NotationalTonicContext.self) var notationalTonalContext
    public init() { }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView()
            PitchMultitouchView { touches in
                instrumentalContext.setTonicLocations(
                    tonicLocations: touches,
                    tonalContext: tonalContext,
                    notationalTonicContext: notationalTonalContext
                )
            }
        }
        .onPreferenceChange(TonicRectsKey.self) { tonicRectInfos in
            Task { @MainActor in
                instrumentalContext.tonicRectInfos = tonicRectInfos
            }
        }
        .coordinateSpace(name: "TonicPickerSpace")
    }
}
