import SwiftUI
import SwiftData

public struct ColorPaletteManagerView: View {
    let instrument: MusicalInstrument    
    public init(instrument: MusicalInstrument) { self.instrument = instrument}

    @Environment(\.dismiss) private var dismiss
    
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
                ColorPaletteListView(instrument: instrument)
                ColorPaletteEditorView(instrument: instrument)
                ColorPalettePreviewView(instrument: instrument)
            }
        }
#if !os(macOS)
        .environment(\.editMode, .constant(.active))
        .navigationBarHidden(true)
#endif
    }
}

