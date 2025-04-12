import SwiftUI

struct IntervalColorPaletteImage: View {
    let intervalColorPalette: IntervalColorPalette
    
    var body: some View {
        Image(systemName: "swatchpalette")
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                intervalColorPalette.neutralColor,
                intervalColorPalette.majorColor,
                intervalColorPalette.minorColor
            )
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(intervalColorPalette.cellBackgroundColor)
            )
    }
}
