import SwiftUI

public struct ModeKeyboardView: Identifiable, View {
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var tonalContext: TonalContext
    
    public let id = UUID()
    public init() { }
    public var body: some View {
        ZStack {
            ModePickerView()            
            KeyboardKeyMultitouchView { touches in
                instrumentalContext.setModeLocations(
                    modeLocations: touches,
                    tonalContext: tonalContext
                )
            }            
        }
        .onPreferenceChange(ModeRectsKey.self) { modeRectInfos in
            Task { @MainActor in
                instrumentalContext.modeRectInfos = modeRectInfos
            }
        }
    }
}
