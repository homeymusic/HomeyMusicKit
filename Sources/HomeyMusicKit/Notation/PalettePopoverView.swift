import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(\.modelContext) var modelContext
        
    @Query(
        filter: #Predicate<ColorPalette> { $0.isSystemPalette == true },
        sort: \ColorPalette.systemPosition, order: .forward
    ) var systemColorPalettes: [ColorPalette]
    
    @Query(
        filter: #Predicate<ColorPalette> { $0.isSystemPalette == false },
        sort: \ColorPalette.customPosition, order: .forward
    ) var customColorPalettes: [ColorPalette]

    /// When non-nil, we'll show the AddPaletteSheet
    @State private var colorPaletteToAdd: ColorPalette?

    var body: some View {
        /// Split palettes by `isSystemPalette`
        VStack {
            // ----------------------------------
            // 1) System Palettes (no delete/move)
            // ----------------------------------
            NavigationStack {
                List(systemColorPalettes) { palette in
                    HStack {
                        ColorPaletteImage(colorPalette: palette)
                        Text(palette.name)
                        Spacer()
                        if palette.name == notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())  // entire row tappable
                    .onTapGesture {
                        notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = palette.name
                        notationalContext.saveColorPaletteName()
                    }
                }
            }
            .frame(minWidth: 500, minHeight: 200)

            // ------------------------------------
            // 2) Custom Palettes (delete & reorder)
            // ------------------------------------
            NavigationStack {
                List {
                    ForEach(customColorPalettes) { palette in
                        HStack {
                            ColorPaletteImage(colorPalette: palette)
                            Text(palette.name)
                            Spacer()
                            if palette.name == notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = palette.name
                            notationalContext.saveColorPaletteName()
                        }
                    }
                    .onDelete(perform: deleteColorPalettes)
                    .onMove(perform: moveColorPalettes)
                }
                .toolbar {
                    EditButton()
                }
                .navigationTitle("Custom Palettes")
                // "Add" button at the bottom of the list or in a toolbar
                 .safeAreaInset(edge: .bottom) {
                     Button {
                         // Create a "blank" palette—by default let's pick .movable,
                         // but the user can change it in the sheet
                         colorPaletteToAdd = ColorPalette(
                             name: "",
                             customPosition: customColorPalettes.count + 1,
                             paletteType: .movable,
                             isSystemPalette: false
                         )
                     } label: {
                         Label("Create Custom Palette", systemImage: "plus")
                             .padding()
                             .frame(maxWidth: .infinity)
                     }
                 }

            }
            .frame(minWidth: 500, minHeight: 300)
        }
        .sheet(item: $colorPaletteToAdd) { blankPalette in
            AddPaletteSheet(
                initialPalette: blankPalette
            ) { newPalette in
                notationalContext.colorPaletteName[instrumentalContext.instrumentChoice] = newPalette.name
                notationalContext.saveColorPaletteName()
            }
        }
    }

    // ------------------------------------
    // DELETE
    // ------------------------------------
    private func deleteColorPalettes(at offsets: IndexSet) {
        // Because we're calling this inside our custom list,
        // the `offsets` refer to the customColorPalettes array's rows.
        // So first re-construct which items these offsets actually map to.
        let customColorPalettes = customColorPalettes.filter { !$0.isSystemPalette }

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
        var s = customColorPalettes.filter { !$0.isSystemPalette }.sorted { $0.customPosition! < $1.customPosition! }

        s.move(fromOffsets: source, toOffset: destination)
        for (index, item) in s.enumerated() {
            item.customPosition = index
        }
        try? self.modelContext.save()
    }
}
