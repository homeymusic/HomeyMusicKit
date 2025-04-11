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
                    .frame(width: geo.size.width / 3)
                    
                    VStack {
                        Text("Edit Here")
                    }
                    .frame(width: geo.size.width / 3)
                    
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

struct ColorPaletteTypeSelectorView: View {
    @Binding var chosenType: ColorPaletteType

    var body: some View {
        // A horizontal stack that mimics a segmented control
        HStack(spacing: 0) {
            // First segment: .movable
            segmentButton(for: .interval, icon: "swatchpalette")
            
            // Second segment: .fixed
            segmentButton(for: .pitch, icon: "swatchpalette.fill")
        }
        .background(Color.systemGray6) // the "bar" background
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// A single "segment" in our custom control.
    private func segmentButton(for type: ColorPaletteType, icon: String) -> some View {
        let isSelected = (type == chosenType)
        
        return Button(action: {
            // Only set if we're not already that type
            if !isSelected {
                chosenType = type
            }
        }) {
            // Combine an icon + text in one row
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(type.rawValue.capitalized)
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(minWidth: 80) // force a bit of width
            .background(isSelected ? Color.systemGray2 : Color.clear)
        }
        .disabled(isSelected) // disable tap if it's already selected
    }

}
