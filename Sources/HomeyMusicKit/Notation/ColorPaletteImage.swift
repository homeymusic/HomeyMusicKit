import SwiftUI

struct ColorPaletteImage: View {
    let colorPalette: ColorPalette
    
    var body: some View {
        switch colorPalette.paletteType {
        case .pitch:
            Image(systemName: "swatchpalette.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    colorPalette.naturalColor,
                    colorPalette.accidentalColor,
                    colorPalette.outlineColor
                )
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(.black)
                )

        case .interval:
            Image(systemName: "swatchpalette")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    colorPalette.neutralColor,
                    colorPalette.majorColor,
                    colorPalette.minorColor
                )
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(colorPalette.baseColor)
                )
        }
    }
}

