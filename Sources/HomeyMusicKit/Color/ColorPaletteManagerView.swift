import SwiftUI
import SwiftData

public struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(InstrumentalContext.self) var instrumentalContext
    
    public init() {}
    
    public var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "paintbrush.pointed.fill")
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .padding(.top, 11)
            HStack(spacing: 0) {
                ColorPaletteListView()
                ColorPaletteEditorView()
                ColorPalettePreviewView()
            }
        }
#if !os(macOS)
        .environment(\.editMode, .constant(.active))
        .navigationBarHidden(true)
#endif
    }
}

