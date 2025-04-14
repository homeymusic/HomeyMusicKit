import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "paintbrush.pointed.fill")
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .foregroundColor(.systemGray6)
                        )
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(.systemGray6)
                    )
                }
            }
            .padding(.top, 11)
            HStack(spacing: 0) {
                ColorPaletteListView()
                ColorPaletteEditorView()
                    .id(notationalContext.colorPalettes[instrumentalContext.instrumentChoice]!.id)
                ColorPalettePreviewView()
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationBarHidden(true)
    }
}

