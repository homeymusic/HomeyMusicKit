import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @State var colorPalette: ColorPalette?
    
    // The raw queries:
    @Query(sort: \ColorPalette.intervalPosition, order: .forward)
    private var intervalColorPalettes: [ColorPalette]
    
    @Query(sort: \ColorPalette.pitchPosition, order: .forward)
    private var pitchColorPalettes: [ColorPalette]
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left side: reorderable list
                List {
                    Section("\(ColorPaletteType.interval.rawValue)s") {
                        ForEach(intervalColorPalettes.filter { $0.paletteType == .interval }) { palette in
                            ColorPaletteGridRow(colorPalette: palette)
                        }
                        .onMove(perform: moveIntervals)
                    }
                    
                    Section("\(ColorPaletteType.pitch.rawValue)s") {
                        ForEach(pitchColorPalettes.filter { $0.paletteType == .pitch }) { palette in
                            ColorPaletteGridRow(colorPalette: palette)
                        }
                        .onMove(perform: movePitches)
                    }
                }
                .listStyle(.insetGrouped)
                .frame(width: 300)  // or use .layoutPriority(1) if you like
                
                VStack(alignment: .leading) {
                    
                    Text("Selected Palette: \(colorPalette?.name ?? "")")
                        .font(.title2)
                        .padding()
                    
                    Text("Palette Type: \(colorPalette?.paletteType.rawValue ?? "")")
                        .padding([.leading, .trailing, .bottom])
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "swatchpalette")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("+")
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
        .onAppear {
            colorPalette = ColorPalette.fetchColorPalette(
                colorPaletteName: notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]!,
                modelContext: modelContext
            )
        }
        .onChange(of: notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]) {
            colorPalette = ColorPalette.fetchColorPalette(
                colorPaletteName: notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]!,
                modelContext: modelContext
            )
        }
    }
    
    // MARK: - The List
    
    
    // MARK: - Detail Pane
    
    // ---------------------------------
    // Move intervals
    // ---------------------------------
    private func moveIntervals(from source: IndexSet, to destination: Int) {
        var palettes = intervalColorPalettes.filter { $0.paletteType == .interval }
        palettes.move(fromOffsets: source, toOffset: destination)
        for (index, item) in palettes.enumerated() {
            item.intervalPosition = index
        }
        try? modelContext.save()
    }
    
    // ---------------------------------
    // Move pitches
    // ---------------------------------
    private func movePitches(from source: IndexSet, to destination: Int) {
        var palettes = pitchColorPalettes.filter { $0.paletteType == .pitch }
        palettes.move(fromOffsets: source, toOffset: destination)
        for (index, item) in palettes.enumerated() {
            item.pitchPosition = index
        }
        try? modelContext.save()
    }
}
