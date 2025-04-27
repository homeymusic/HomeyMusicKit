import SwiftUI

public struct IntervalColorPaletteImage: View {
    public let intervalColorPalette: IntervalColorPalette
    
    public init(intervalColorPalette: IntervalColorPalette) {
        self.intervalColorPalette = intervalColorPalette
    }
    
    public var body: some View {
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
