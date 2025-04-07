import SwiftUI

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
            
            Image(systemName: "swatchpalette")
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

