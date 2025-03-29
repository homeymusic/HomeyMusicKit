import SwiftUI

struct PalettePopoverView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        VStack(spacing: 10.0) {
            
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
