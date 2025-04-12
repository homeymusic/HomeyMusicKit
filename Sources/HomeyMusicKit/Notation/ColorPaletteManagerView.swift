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
                    
                    // 3) The Preview
                    ColorPalettePreviewView(colorPalette: colorPalette)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "swatchpalette")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
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
        List {
            Section("Interval Palettes") {
                ForEach(intervalColorPalettes) { palette in
                    ColorPaletteListRow(listedColorPalette: palette)
                }
                .onMove(perform: onMoveIntervals)
                
                Button(action: {
                    print("Add Interval Palette")
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                        Text("Add Interval Palette")
                        Spacer()
                    }
                    .foregroundColor(.systemGray5)
                }
                .listRowBackground(Color.systemGray)
            }
            
            Section("Pitch Palettes") {
                ForEach(pitchColorPalettes) { palette in
                    ColorPaletteListRow(listedColorPalette: palette)
                }
                .onMove(perform: onMovePitches)
                
                Button(action: {
                    print("Add Pitch Palette")
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                        Text("Add Pitch Palette")
                        Spacer()
                    }
                    .foregroundColor(.systemGray5)
                }
                .listRowBackground(Color.systemGray)
            }
        }
        .background(Color.systemGray6)
        .scrollContentBackground(.hidden)
    }
}

struct ColorPaletteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var colorPalette: ColorPalette
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $colorPalette.name)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        colorPalette.name = colorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
            }
            
            if colorPalette.paletteType == .interval {
                Section("Interval Colors") {
                    ColorPicker("Minor", selection: $colorPalette.minorColor)
                    ColorPicker("Neutral", selection: $colorPalette.neutralColor)
                    ColorPicker("Major", selection: $colorPalette.majorColor)
                    ColorPicker("Background", selection: $colorPalette.cellBackgroundColor)
                }
            } else if colorPalette.paletteType == .pitch {
                Section("Pitch Colors") {
                    ColorPicker("Natural", selection: $colorPalette.naturalColor)
                    ColorPicker("Accidental", selection: $colorPalette.accidentalColor)
                    ColorPicker("Outline", selection: $colorPalette.outlineColor)
                }
            }
        }
        .background(Color.systemGray6)
        .scrollContentBackground(.hidden)
    }
}

struct ColorPalettePreviewView: View {
    let colorPalette: ColorPalette
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section("Preview") {
                    Grid {
                        switch colorPalette.paletteType {
                        case .interval:
                            intervalPreview
                        case .pitch:
                            pitchPreview
                        }
                    }
                    .frame(height: geometry.size.height * 0.8)
                    .listRowBackground(Color.black)
                }
            }
            .background(Color.systemGray6)
            .scrollContentBackground(.hidden)
        }
    }
    
    // MARK: - Interval Preview
    private var intervalPreview: some View {
        Group {
            GridRow {
                Text("MINOR")
                Text("NEUTRAL")
                Text("MAJOR")
            }
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
            }
            GridRow {
                VStack {
                    Text("ACTIVATED")
                    Text("MINOR")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("NEUTRAL")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("MAJOR")
                }
            }
        }
        .font(.caption2).foregroundColor(.systemGray)
            .gridCellAnchor(.center)
    }
    
    // MARK: - Pitch Preview
    private var pitchPreview: some View {
        Group {
            GridRow {
                Text("NATURAL")
                Text("ACCIDENTAL")
            }
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
            }
            GridRow {
                VStack {
                    Text("ACTIVATED")
                    Text("NATURAL")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("ACCIDENTAL")
                }
            }
        }
        .font(.caption2).foregroundColor(.systemGray)
            .gridCellAnchor(.center)
    }
}

struct ColorPaletteListRow: View {
    let listedColorPalette: ColorPalette
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        
        let colorPalette: ColorPalette = notationalContext.colorPalette
        
        HStack {
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

