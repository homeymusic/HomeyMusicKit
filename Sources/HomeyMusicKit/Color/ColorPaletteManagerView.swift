import SwiftUI
import SwiftData

struct ColorPaletteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    
                    // 1) The List of all Palettes (interval + pitch)
                    ColorPaletteListView()
                    
                    // 2) The Editor
                    ColorPaletteEditorView()
                    
                    // 3) The Preview
                    ColorPalettePreviewView()
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
    
}

struct ColorPaletteListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    @Query
    public var intervalColorPalettes: [IntervalColorPalette]
    
    @Query
    public var pitchColorPalettes: [PitchColorPalette]
    
    var body: some View {
        
        var sortedIntervalColorPalettes: [IntervalColorPalette] {
            intervalColorPalettes.sorted { $0.position < $1.position }
        }
        
        var sortedPitchColorPalettes: [PitchColorPalette] {
            pitchColorPalettes.sorted { $0.position < $1.position }
        }

        List {
            Section("Interval Palettes") {
                ForEach(sortedIntervalColorPalettes) { intervalColorPalette in
                    ColorPaletteListRow(listedColorPalette: intervalColorPalette)
                }
                .onMove(perform: moveIntervalPalettes)
                Button(action: addIntervalPalette) {
                    HStack {
                        Image(systemName: "swatchpalette")
                            .foregroundColor(.clear)
                            .padding(3)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .foregroundColor(.clear)
                            )
                            .overlay {
                                Image(systemName: "plus.circle.fill")
                            }
                        Text("Add Interval Palette")
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
            }
            
            Section("Pitch Palettes") {
                ForEach(sortedPitchColorPalettes) { pitchColorPalette in
                    ColorPaletteListRow(listedColorPalette: pitchColorPalette)
                }
                .onMove(perform: movePitchPalettes)
                
                Button(action: addPitchPalette) {
                    HStack {
                        Image(systemName: "swatchpalette")
                            .foregroundColor(.clear)
                            .padding(3)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .foregroundColor(.clear)
                            )
                            .overlay {
                                Image(systemName: "plus.circle.fill")
                            }
                        Text("Add Pitch Palette")
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .background(Color.systemGray6)
        .scrollContentBackground(.hidden)
    }
    
    private func addIntervalPalette() {
        let position: Int = (intervalColorPalettes.map({ $0.position}).max() ?? -1) + 1

        let intervalPalette = IntervalColorPalette(
            name: "New Interval \(position)",
            position: position
        )
        modelContext.insert(intervalPalette)
        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = intervalPalette
        notationalContext.colorPalette = intervalPalette
    }
    
    private func addPitchPalette() {
        let position: Int = (pitchColorPalettes.map({ $0.position}).max() ?? -1) + 1
        
        let pitchPalette = PitchColorPalette(
            name: "New Pitch \(position)",
            position: position
        )
        modelContext.insert(pitchPalette)
        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = pitchPalette
        notationalContext.colorPalette = pitchPalette
    }
    
    private func moveIntervalPalettes(from source: IndexSet, to destination: Int) {
        var palettes = intervalColorPalettes
        palettes.move(fromOffsets: source, toOffset: destination)
        for (index, item) in palettes.enumerated() {
            item.position = index
        }
    }
    
    private func movePitchPalettes(from source: IndexSet, to destination: Int) {
        var palettes = pitchColorPalettes
        palettes.move(fromOffsets: source, toOffset: destination)
        for (index, item) in palettes.enumerated() {
            item.position = index
        }
    }

    
}

struct ColorPaletteEditorView: View {
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        let colorPalette = notationalContext.colorPalette
        if colorPalette is IntervalColorPalette {
            IntervalColorPaletteEditorView(intervalColorPalette: colorPalette as! IntervalColorPalette)
        } else if colorPalette is PitchColorPalette {
            PitchColorPaletteEditorView(pitchColorPalette: colorPalette as! PitchColorPalette)
        }
    }
}

struct IntervalColorPaletteEditorView: View {
    @Bindable var intervalColorPalette: IntervalColorPalette
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $intervalColorPalette.name)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        intervalColorPalette.name = intervalColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .disabled(intervalColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Name")
                    if intervalColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            
            Section {
                ColorPicker("Minor", selection: $intervalColorPalette.minorColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Neutral", selection: $intervalColorPalette.neutralColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Major", selection: $intervalColorPalette.majorColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Background", selection: $intervalColorPalette.cellBackgroundColor)
                    .disabled(intervalColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Interval Colors")
                    if intervalColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }

            if !intervalColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = IntervalColorPalette.homey
                        notationalContext.colorPalette = IntervalColorPalette.homey
                        modelContext.delete(intervalColorPalette)
                    }
                }
            }
        }
        .background(Color.systemGray6)
        .scrollContentBackground(.hidden)
    }
}

struct PitchColorPaletteEditorView: View {
    @Bindable var pitchColorPalette: PitchColorPalette
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $pitchColorPalette.name)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        pitchColorPalette.name = pitchColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .disabled(pitchColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Name")
                    if pitchColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }

            Section {
                ColorPicker("Natural", selection: $pitchColorPalette.naturalColor)
                    .disabled(pitchColorPalette.isSystemPalette)
                ColorPicker("Accidental", selection: $pitchColorPalette.accidentalColor)
                    .disabled(pitchColorPalette.isSystemPalette)
                ColorPicker("Outline", selection: $pitchColorPalette.outlineColor)
                    .disabled(pitchColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Pitch Colors")
                    if pitchColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }

            if !pitchColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = PitchColorPalette.ivory
                        notationalContext.colorPalette = PitchColorPalette.ivory
                        modelContext.delete(pitchColorPalette)
                    }
                }
            }
        }
        .background(Color.systemGray6)
        .scrollContentBackground(.hidden)
    }
}

struct ColorPalettePreviewView: View {
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        let colorPalette = notationalContext.colorPalette
        GeometryReader { geometry in
            List {
                Section("Preview") {
                    Grid {
                        if colorPalette is IntervalColorPalette {
                            intervalPreview
                        } else {
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
            
            switch listedColorPalette {
            case let intervalPalette as IntervalColorPalette:
                IntervalColorPaletteImage(intervalColorPalette: intervalPalette)
                    .foregroundColor(.white)
            case let pitchPalette as PitchColorPalette:
                PitchColorPaletteImage(pitchColorPalette: pitchPalette)
                    .foregroundColor(.white)
            default:
                // Handle unexpected type or do nothing
                EmptyView()
            }

            Text(listedColorPalette.name)
                .lineLimit(1)
                .foregroundColor(.white)
            
            if listedColorPalette.isSystemPalette {
                Image(systemName: "lock")
            }
            
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
