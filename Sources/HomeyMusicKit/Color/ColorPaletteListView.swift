import SwiftUI
import SwiftData

struct ColorPaletteListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    @Query
    public var intervalColorPalettes: [IntervalColorPalette]
    
    @Query
    public var pitchColorPalettes: [PitchColorPalette]
    
    init() {
        self._intervalColorPalettes = Query(sort: \.position)
        self._pitchColorPalettes = Query(sort: \.position)
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                Section("Interval Palettes") {
                    ForEach(intervalColorPalettes) { intervalColorPalette in
                        ColorPaletteListRow(listedColorPalette: intervalColorPalette)
                            .id(intervalColorPalette.id)
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
                .listRowBackground(Color.systemGray5)
                
                Section("Pitch Palettes") {
                    ForEach(pitchColorPalettes) { pitchColorPalette in
                        ColorPaletteListRow(listedColorPalette: pitchColorPalette)
                            .id(pitchColorPalette.id)
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
                .listRowBackground(Color.systemGray5)
            }
            .onAppear {
                 // Get the currently selected palette.
                 let selectedPalette = notationalContext.colorPalettes[instrumentalContext.instrumentChoice]
                 if let id = selectedPalette?.id {
                     scrollProxy.scrollTo(id, anchor: .center)
                 }
             }
        }
    }
    
    private func addIntervalPalette() {
        let position: Int = (intervalColorPalettes.map({ $0.position}).max() ?? -1) + 1

        let intervalPalette = IntervalColorPalette(
            name: "",
            position: position
        )
        modelContext.insert(intervalPalette)
        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = intervalPalette
        buzz()
    }
    
    private func addPitchPalette() {
        let position: Int = (pitchColorPalettes.map({ $0.position}).max() ?? -1) + 1
        
        let pitchPalette = PitchColorPalette(
            name: "",
            position: position
        )
        modelContext.insert(pitchPalette)
        notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = pitchPalette
        buzz()
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

struct ColorPaletteListRow: View {
    let listedColorPalette: ColorPalette
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        
        let colorPalette: ColorPalette = notationalContext.colorPalette(for: instrumentalContext.instrumentChoice)
        
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
            
            if listedColorPalette.id == colorPalette.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
            } else {
                Image(systemName: "checkmark")
                    .foregroundColor(.clear)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if (colorPalette.id != listedColorPalette.id) {
                buzz()
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice] = listedColorPalette
            }
        }
    }
}
