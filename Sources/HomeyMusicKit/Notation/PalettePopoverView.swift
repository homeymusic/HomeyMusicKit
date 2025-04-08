import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(\.modelContext) var modelContext
    
    @Query(
        sort: \ColorPalette.intervalPosition, order: .forward
    ) var intervalColorPalettes: [ColorPalette]
    
    @Query(
        sort: \ColorPalette.pitchPosition, order: .forward
    ) var pitchColorPalettes: [ColorPalette]
    
    /// When non-nil, we'll show the AddPaletteSheet
    @State private var colorPaletteToAdd: ColorPalette?
    
    var body: some View {
        
        let pitchColorPalettes = pitchColorPalettes.filter({$0.paletteType == .pitch})
        let intervalColorPalettes = intervalColorPalettes.filter({$0.paletteType == .interval})

        VStack(spacing: 0.0) {
            Grid {
                
                ForEach(intervalColorPalettes, id: \.self) {intervalColorPalette in
                    ColorPaletteGridRow(colorPalette: intervalColorPalette)
                }
                
                Divider()
                
                GridRow {
                    Image(systemName: "pencil.and.outline")
                        .gridCellAnchor(.center)
                        .foregroundColor(.white)
                    Toggle(notationalContext.outlineLabel,
                           isOn: notationalContext.outlineBinding(for: instrumentalContext.instrumentChoice))
                    .gridCellColumns(2)
                    .tint(Color.gray)
                    .foregroundColor(.white)
                }

                Divider()
                
                ForEach(pitchColorPalettes, id: \.self) {pitchColorPalette in
                    ColorPaletteGridRow(colorPalette: pitchColorPalette)
                }

            }
            .padding(10)
        }
    }
    
    // ------------------------------------
    // DELETE
    // ------------------------------------
    private func deleteColorPalettes(at offsets: IndexSet) {
        // Because we're calling this inside our custom list,
        // the `offsets` refer to the customColorPalettes array's rows.
        // So first re-construct which items these offsets actually map to.
        let customColorPalettes = pitchColorPalettes.filter { !$0.isSystemPalette }
        
        for offset in offsets {
            let colorPalette = customColorPalettes[offset]
            if !colorPalette.isSystemPalette {
                modelContext.delete(colorPalette)
                notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = HomeyMusicKit.defaultColorPaletteName
            }
        }
    }
    
    // ------------------------------------
    // MOVE
    // ------------------------------------
    private func moveColorPalettes(from source: IndexSet, to destination: Int) {
        // Rebuild the array referencing only custom items
        var s = pitchColorPalettes.filter { !$0.isSystemPalette }.sorted { $0.pitchPosition! < $1.pitchPosition! }
        
        s.move(fromOffsets: source, toOffset: destination)
        for (index, item) in s.enumerated() {
            item.pitchPosition = index
        }
        try? self.modelContext.save()
    }
}

struct ColorPaletteGridRow: View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

    let colorPalette: ColorPalette
    
    var body: some View {
        GridRow {
            HStack {
                ColorPaletteImage(colorPalette: colorPalette)
                    .foregroundColor(.accentColor)
                
                Text(colorPalette.name)
                    .foregroundColor(.accentColor)
                    .fixedSize(horizontal: true, vertical: false)
                
                Spacer() // push the checkmark to the trailing side
                if colorPalette.name == notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.clear)
                }
            }
            .frame(maxWidth: .infinity)
            // Merge columns
            .gridCellColumns(3)
            // One shape covering the entire HStack
            .contentShape(Rectangle())
            .onTapGesture {
                notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = colorPalette.name
                notationalContext.saveColorPaletteName()
            }
        }
        .padding(3)
    }
}
