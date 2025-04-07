import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(\.modelContext) var modelContext
    
    @Query var colorPalettes: [ColorPalette]

    /// When non-nil, we'll show the AddPaletteSheet
    @State private var colorPaletteToAdd: ColorPalette?

    var body: some View {
        Form {
            // MARK: - Single Inline Picker (No Grouping)
            Picker(
                "Choose a Palette",
                selection: notationalContext.colorPaletteNameBinding(
                    for: instrumentalContext.instrumentChoice
                )
            ) {
                ForEach(colorPalettes, id: \.name) { palette in
                    HStack {
                        ColorPaletteImage(colorPalette: palette)
                        Text(palette.name)
                    }
                    .tag(palette.name)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()

            // MARK: - Add Palette Button
            Section {
                Button {
                    // Create a blank palette with a default type
                    colorPaletteToAdd = ColorPalette(
                        name: "",
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
