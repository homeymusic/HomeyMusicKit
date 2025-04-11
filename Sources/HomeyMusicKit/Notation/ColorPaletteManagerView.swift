import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(TonalContext.self) var tonalContext

    // The raw queries:
    @Query(sort: \ColorPalette.intervalPosition, order: .forward)
    private var intervalColorPalettes: [ColorPalette]
    
    @Query(sort: \ColorPalette.pitchPosition, order: .forward)
    private var pitchColorPalettes: [ColorPalette]
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    
                    // MARK: Color Palettes List
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
                    .frame(width: geo.size.width / 3)
                    
                    
                    // MARK: Color Palette Editor
                    // TODO: Build the editor
                    VStack {
                        Text("Edit Here")
                    }
                    .frame(width: geo.size.width / 3)
                    
                    // MARK: Color Palette Preview
                    Grid {
                        if notationalContext.colorPalette.paletteType == .interval {
                            GridRow {
                                Text("".uppercased())
                                    .font(.footnote)
                                Text("minor".uppercased())
                                    .font(.footnote)
                                Text("neutral".uppercased())
                                    .font(.footnote)
                                Text("major".uppercased())
                                    .font(.footnote)
                            }
                            GridRow {
                                Text("inactive".uppercased())
                                    .font(.footnote)
                                PitchCellPreview(
                                    isActivated: false,
                                    majorMinor: .minor,
                                    consonanceDissonance: .consonant,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: false,
                                    majorMinor: .neutral,
                                    consonanceDissonance: .tonic,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: false,
                                    majorMinor: .major,
                                    consonanceDissonance: .consonant,
                                    isNatural: true,
                                    isOutlined: true
                                )
                            }
                            GridRow {
                                Text("active".uppercased())
                                    .font(.footnote)
                                PitchCellPreview(
                                    isActivated: true,
                                    majorMinor: .minor,
                                    consonanceDissonance: .consonant,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: true,
                                    majorMinor: .neutral,
                                    consonanceDissonance: .tonic,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: true,
                                    majorMinor: .major,
                                    consonanceDissonance: .consonant,
                                    isNatural: true,
                                    isOutlined: true
                                )
                            }
                        } else if notationalContext.colorPalette.paletteType == .pitch {
                            GridRow {
                                Text("".uppercased())
                                    .font(.footnote)
                                Text("natural".uppercased())
                                    .font(.footnote)
                                Text("accidental".uppercased())
                                    .font(.footnote)
                            }
                            GridRow {
                                Text("inactive".uppercased())
                                    .font(.footnote)
                                PitchCellPreview(
                                    isActivated: false,
                                    majorMinor: .neutral,
                                    consonanceDissonance: .tonic,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: false,
                                    majorMinor: .major,
                                    consonanceDissonance: .consonant,
                                    isNatural: false,
                                    isOutlined: true
                                )
                            }
                            GridRow {
                                Text("active".uppercased())
                                    .font(.footnote)
                                PitchCellPreview(
                                    isActivated: true,
                                    majorMinor: .neutral,
                                    consonanceDissonance: .tonic,
                                    isNatural: true,
                                    isOutlined: true
                                )
                                PitchCellPreview(
                                    isActivated: true,
                                    majorMinor: .major,
                                    consonanceDissonance: .consonant,
                                    isNatural: false,
                                    isOutlined: true
                                )
                            }
                        }
                    }
                    .frame(width: geo.size.width / 3)
                    .padding(9)
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
        }
    }
    
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

