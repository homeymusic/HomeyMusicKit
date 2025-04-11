import SwiftUI
import SwiftData

struct ColorPalettePopoverView: View {
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
    
    var body: some View {
        
        let pitchColorPalettes = pitchColorPalettes.filter({$0.paletteType == .pitch})
        let intervalColorPalettes = intervalColorPalettes.filter({$0.paletteType == .interval})
        
        VStack(spacing: 0.0) {
            Grid {
                
                ForEach(intervalColorPalettes, id: \.self) {intervalColorPalette in
                    ColorPaletteGridRow(listedColorPalette: intervalColorPalette)
                }
                
                Divider()
                
                GridRow {
                    Image(systemName: "pencil.and.outline")
                        .gridCellAnchor(.center)
                        .foregroundColor(.white)
                    Toggle(
                        notationalContext.outlineLabel,
                        isOn: notationalContext.outlineBinding(for: instrumentalContext.instrumentChoice)
                    )
                    .tint(Color.gray)
                    .foregroundColor(.white)
                    .onChange(of: notationalContext.outline[instrumentalContext.instrumentChoice]) {
                        buzz()
                    }
                }
                
                Divider()
                
                ForEach(pitchColorPalettes, id: \.self) {pitchColorPalette in
                    ColorPaletteGridRow(listedColorPalette: pitchColorPalette)
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
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = ColorPalette.homey
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

struct ColorPaletteRow: View {
    let listedColorPalette: ColorPalette
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        
        let colorPalette: ColorPalette = notationalContext.colorPalette
        
        ColorPaletteImage(colorPalette: listedColorPalette)
            .foregroundColor(.white)
        
        Text(listedColorPalette.name)
            .lineLimit(1)
            .foregroundColor(.white)
        
        Spacer()
        
        if listedColorPalette.name == colorPalette.name {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
        } else {
            Image(systemName: "checkmark")
                .foregroundColor(.clear)
        }
    }
}

struct ColorPaletteGridRow: View {
    let listedColorPalette: ColorPalette
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        
        let colorPalette: ColorPalette = notationalContext.colorPalette
        
        GridRow {
            HStack {
                ColorPaletteRow(listedColorPalette: listedColorPalette)
            }
        }
        .gridCellColumns(2)
        .gridCellAnchor(.leading)
        .contentShape(Rectangle())
        .onTapGesture {
            if (colorPalette.name != listedColorPalette.name) {
                buzz()
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = listedColorPalette
                notationalContext.colorPalette = listedColorPalette
            }
        }
        .padding(3)
    }
}

