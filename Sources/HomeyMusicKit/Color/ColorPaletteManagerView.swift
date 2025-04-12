import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    
                    // 1) The List of all Palettes (interval + pitch)
                    ColorPaletteListView()
                    
                    // 2) The Editor
                    ColorPaletteEditorView()
                    
                    // 3) The Preview
                    ColorPalettePreviewView()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "swatchpalette")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .environment(\.editMode, .constant(.active))
            }
        }
        .presentationBackground(.black)
    }
    
}

