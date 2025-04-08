import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(\.modelContext) var modelContext
        
    @Query(sort: \ColorPalette.position, order: .forward) var colorPalettes: [ColorPalette]
        
    /// When non-nil, we'll show the AddPaletteSheet
    @State private var colorPaletteToAdd: ColorPalette?

    func deleteColorPalettes(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our query
            let colorPalette = colorPalettes[offset]

            // delete it from the context
            if !colorPalette.isSystemPalette {
                modelContext.delete(colorPalette)
                notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = HomeyMusicKit.defaultColorPaletteName
            }
        }
    }
    
    func moveColorPalettes(from source: IndexSet, to destination: Int) {
        var s = colorPalettes.sorted(by: { $0.position < $1.position })
        s.move(fromOffsets: source, toOffset: destination)
        for (index, item) in s.enumerated() {
            item.position = index
        }
        try? self.modelContext.save()
    }
    
    var body: some View {
        Form {
            // MARK: - Picker
            List {
                ForEach(colorPalettes) { palette in
                    HStack {
                        ColorPaletteImage(colorPalette: palette)
                        Text(palette.name)
                    }
                    .contentShape(Rectangle())  // Make entire row tappable
                    .onTapGesture {
                        // Set the current selected palette in your context
                        notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = palette.name
                        notationalContext.saveColorPaletteName()
                    }
                    // Highlight if it’s the chosen palette
                    .listRowBackground(
                        palette.name == notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]
                            ? Color.accentColor.opacity(0.2)
                            : Color.clear
                    )
                }
                .onDelete(perform: deleteColorPalettes)
                .onMove(perform: moveColorPalettes)
            }

            // MARK: - Add Palette Button
            Section {
                Button {
                    // Create a blank palette with a default type
                    colorPaletteToAdd = ColorPalette(
                        name: "",
                        position: colorPalettes.count + 1,
                        paletteType: .movable, // default, user will choose in the sheet
                        isSystemPalette: false
                    )
                } label: {
                    Label("Create Color Palette", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
            }

            // MARK: - Outline Toggle (unchanged)
            Section {
                Grid {
                    GridRow {
                        Image(systemName: "pencil.and.outline")
                            .gridCellAnchor(.center)
                            .foregroundColor(.white)

                        Toggle(
                            notationalContext.outlineLabel,
                            isOn: notationalContext.outlineBinding(
                                for: instrumentalContext.instrumentChoice
                            )
                        )
                        .tint(Color.gray)
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 500)
        // MARK: - Sheet for Creating a New Palette
        .sheet(item: $colorPaletteToAdd) { blankPalette in
            AddPaletteSheet(
                initialPalette: blankPalette
            ) { newPalette in
                /// After creation, select the newly added palette
                notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = newPalette.name
                notationalContext.saveColorPaletteName()
            }
        }
    }
}
