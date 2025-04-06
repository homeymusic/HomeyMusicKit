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
            
            Picker("", selection: notationalContext.colorPaletteNameBinding(for: instrumentalContext.instrumentChoice)) {
                ForEach(colorPalettes, id: \.name) { palette in
                    Text(palette.name)
                        .tag(palette.name)
                }
            }
            .pickerStyle(.wheel)
            
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
