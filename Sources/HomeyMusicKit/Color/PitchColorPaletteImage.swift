import SwiftUI

struct PitchColorPaletteImage: View {
    let pitchColorPalette: PitchColorPalette
    
    var body: some View {
        Image(systemName: "swatchpalette.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                pitchColorPalette.naturalColor,
                pitchColorPalette.accidentalColor,
                pitchColorPalette.outlineColor
            )
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.black)
            )
    }
}

