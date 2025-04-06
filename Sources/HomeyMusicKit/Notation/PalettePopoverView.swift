import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(NotationalContext.self) var notationalContext
    
    // Fetch existing palettes from SwiftData
    @Query var colorPalettes: [ColorPalette]
    var debugCount: String {
        "Palettes fetched: \(colorPalettes.count)"
    }
    var body: some View {
        @Bindable var notationalContext = notationalContext
        
        VStack {
            List {
                Section("Movable") {
                    ForEach(colorPalettes.filter { $0.paletteType == .movable }, id: \.self) { palette in
                        PaletteRow(palette: palette, selectedPaletteName: $notationalContext.colorPaletteName)
                    }
                }

                Section("Fixed") {
                    ForEach(colorPalettes.filter { $0.paletteType == .fixed }, id: \.self) { palette in
                        PaletteRow(palette: palette, selectedPaletteName: $notationalContext.colorPaletteName)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .frame(minWidth: 250, minHeight: 300)
    }
}

/// A row showing a palette name and an optional checkmark if selected.
private struct PaletteRow: View {
    let palette: ColorPalette
    @Binding var selectedPaletteName: [InstrumentChoice:String]
    @Environment(InstrumentalContext.self) var instrumentalContext

    var body: some View {
        HStack {
            Text(palette.name)

            // Show checkmark if this palette is selected
            if palette.name == selectedPaletteName[instrumentalContext.instrumentChoice] {
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        // Make the entire row tappable
        .contentShape(Rectangle())
        .onTapGesture {
            // Update the selection
//            selectedPaletteName[instrumentalContext.instrumentChoice] = palette.name
        }
    }
}
