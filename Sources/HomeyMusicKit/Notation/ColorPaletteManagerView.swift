import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(TonalContext.self) var tonalContext
    
    @Query(sort: \ColorPalette.intervalPosition, order: .forward)
    private var intervalColorPalettes: [ColorPalette]
    
    @Query(sort: \ColorPalette.pitchPosition, order: .forward)
    private var pitchColorPalettes: [ColorPalette]
    
    var body: some View {
        let colorPalette: ColorPalette = notationalContext.colorPalette
        
        NavigationStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    
                    // 1) The List of all Palettes (interval + pitch)
                    ColorPaletteListView(
                        intervalColorPalettes: intervalColorPalettes.filter { $0.paletteType == .interval },
                        pitchColorPalettes: pitchColorPalettes.filter { $0.paletteType == .pitch },
                        onMoveIntervals: moveIntervals,
                        onMovePitches: movePitches
                    )
                    
                    // 2) The Editor
                    ColorPaletteEditorView(colorPalette: colorPalette)
                        .padding(5)
                    
                    // 3) The Preview
                    ColorPalettePreviewView(colorPalette: colorPalette)
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
        .presentationBackground(.black)
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

struct ColorPaletteListView: View {
    let intervalColorPalettes: [ColorPalette]
    let pitchColorPalettes: [ColorPalette]
    let onMoveIntervals: (IndexSet, Int) -> Void
    let onMovePitches: (IndexSet, Int) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section("Interval Palettes") {
                    ForEach(intervalColorPalettes) { palette in
                        ColorPaletteListRow(listedColorPalette: palette)
                    }
                    .onMove(perform: onMoveIntervals)
                }
                Button("Create Interval Palette") {
                    print("Create Interval Palette")
                }
                Section("Pitch Palettes") {
                    ForEach(pitchColorPalettes) { palette in
                        ColorPaletteListRow(listedColorPalette: palette)
                    }
                    .onMove(perform: onMovePitches)
                }
                Button("Create Pitch Palette") {
                    print("Create Pitch Palette")
                }
            }
            .background(.black)
            .scrollContentBackground(.hidden)
            
        }
    }
}

struct ColorPaletteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var colorPalette: ColorPalette
    
    var body: some View {
        NavigationStack {            
            Form {
                Section("Name") {
                    TextField("Name", text: $colorPalette.name)
                        .onSubmit {
                            colorPalette.name = colorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                }
                
                if colorPalette.paletteType == .interval {
                    Section("Interval Colors") {
                        ColorPicker("Minor", selection: $colorPalette.minorColor)
                        ColorPicker("Neutral", selection: $colorPalette.neutralColor)
                        ColorPicker("Major", selection: $colorPalette.majorColor)
                        ColorPicker("Base", selection: $colorPalette.baseColor)
                    }
                } else if colorPalette.paletteType == .pitch {
                    Section("Pitch Colors") {
                        ColorPicker("Natural", selection: $colorPalette.naturalColor)
                        ColorPicker("Accidental", selection: $colorPalette.accidentalColor)
                        ColorPicker("Outline", selection: $colorPalette.outlineColor)
                            .disabled(true)
                    }
                }
            }
            .background(.black)
            .scrollContentBackground(.hidden)
        }
    }
}

struct ColorPalettePreviewView: View {
    let colorPalette: ColorPalette
    
    var body: some View {
        Grid {
            switch colorPalette.paletteType {
            case .interval:
                intervalPreview
            case .pitch:
                pitchPreview
            }
        }
    }
    
    // MARK: - Interval Preview
    private var intervalPreview: some View {
        Group {
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                Text("inactive".uppercased()).font(.footnote).foregroundColor(.systemGray)
                    .gridCellAnchor(.leading)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                Text("active".uppercased()).font(.footnote).foregroundColor(.systemGray)
                    .gridCellAnchor(.leading)
            }
            GridRow {
                Text("minor".uppercased()).font(.footnote).foregroundColor(.systemGray)
                Text("neutral".uppercased()).font(.footnote).foregroundColor(.systemGray)
                Text("major".uppercased()).font(.footnote).foregroundColor(.systemGray)
                Text("")
            }
        }
    }
    
    // MARK: - Pitch Preview
    private var pitchPreview: some View {
        Group {
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
                Text("inactive".uppercased()).font(.footnote).foregroundColor(.systemGray)
                    .gridCellAnchor(.leading)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
                Text("active".uppercased()).font(.footnote).foregroundColor(.systemGray)
                    .gridCellAnchor(.leading)
            }
            GridRow {
                Text("natural".uppercased()).font(.footnote).foregroundColor(.systemGray)
                Text("accidental".uppercased()).font(.footnote).foregroundColor(.systemGray)
                Text("").font(.footnote)
            }
        }
    }
}

struct ColorPaletteListRow: View {
    let listedColorPalette: ColorPalette
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        
        let colorPalette: ColorPalette = notationalContext.colorPalette
        
        HStack {
            ColorPaletteRow(listedColorPalette: listedColorPalette)
        }
//        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if (colorPalette.name != listedColorPalette.name) {
                buzz()
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = listedColorPalette
                notationalContext.colorPalette = listedColorPalette
            }
        }
    }
}

