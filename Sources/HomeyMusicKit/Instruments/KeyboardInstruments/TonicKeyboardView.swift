import SwiftUI

public struct TonicKeyboardView: Identifiable, View {
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var tonalContext: TonalContext
    public init() { }
    public let id = UUID()
    
    public var body: some View {
        ZStack {
            TonicPickerView()
            KeyboardKeyMultitouchView { touches in
                instrumentalContext.setTonicLocations(
                    tonicLocations: touches,
                    tonalContext: tonalContext
                )
            }
        }
        .onPreferenceChange(TonicRectsKey.self) { tonicRectInfos in
            Task { @MainActor in
                instrumentalContext.tonicRectInfos = tonicRectInfos
            }
        }
    }
}
