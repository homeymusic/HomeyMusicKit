import SwiftUI

public struct ModeKeyboardView: Identifiable, View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext
    
    public let id = UUID()
    public init() { }
    public var body: some View {
        ZStack {
            ModePickerView()            
            PitchKeyMultitouchView { touches in
                instrumentalContext.setModeLocations(
                    modeLocations: touches,
                    tonalContext: tonalContext,
                    notationalTonicContext: notationalTonicContext
                )
            }
        }
        .onPreferenceChange(ModeRectsKey.self) { modeRectInfos in
            Task { @MainActor in
                instrumentalContext.modeRectInfos = modeRectInfos
            }
        }
        .coordinateSpace(name: "ModePickerSpace")
    }
}
