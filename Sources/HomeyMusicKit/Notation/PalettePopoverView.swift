import SwiftUI
import SwiftData

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(\.modelContext) var modelContext
    @Query var colorPalettes: [ColorPalette]
    
    var body: some View {
        VStack(spacing: 10.0) {
            let _p = print("colorPalettes", colorPalettes)
            ForEach(colorPalettes, id: \.self)  { colorPalette in
                Text(colorPalette.name)
            }
            Button("Add") {
                let names = ["detroit", "pittsburgh", "new york", "los angeles", "chicago"]
                let name = names.randomElement()!
                let colorPalette = ColorPalette(
                    id: UUID(),
                    name: name,
                    paletteType: .movable
                )
                print("colorPalette", colorPalette)
                print("colorPalette.name", colorPalette.name)
                modelContext.insert(colorPalette)
            }
            
            Picker("", selection: notationalContext.colorPaletteBinding(for: instrumentalContext.instrumentChoice)) {
                ForEach(ColorPaletteChoice.allCases, id: \.self) { paletteChoice in
                    Image(systemName: paletteChoice.icon)
                        .tag(paletteChoice)
                }
            }
            .pickerStyle(.segmented)
            
            Grid {
                GridRow {
                    Image(systemName: "pencil.and.outline")
                        .gridCellAnchor(.center)
                        .foregroundColor(.white)
                    Toggle(notationalContext.outlineLabel,
                           isOn: notationalContext.outlineBinding(for: instrumentalContext.instrumentChoice))
                    .tint(Color.gray)
                    .foregroundColor(.white)
                }
            }
        }
        .padding(10)
    }
}
