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
                ForEach(colorPalettes, id: \.name) { colorPalette in
                    HStack {
                        ColorPaletteImage(colorPalette: colorPalette)
                        Text(colorPalette.name)
                            .tag(colorPalette.name)
                    }
                }
            }
            .pickerStyle(.inline)
            
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

struct ColorPaletteImage: View {
    let colorPalette: ColorPalette
    
    var body: some View {
        switch colorPalette.paletteType {
        case .fixed:
            Image(systemName: "swatchpalette.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    colorPalette.naturalColor,
                    colorPalette.accidentalColor,
                    colorPalette.outlineColor
                )
            
        case .movable:
            
            Image(systemName: "swatchpalette.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    colorPalette.neutralColor,
                    colorPalette.majorColor,
                    colorPalette.minorColor
                )
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(colorPalette.baseColor)
                )
        }
    }
}
