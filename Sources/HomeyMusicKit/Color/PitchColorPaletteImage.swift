import SwiftUI

public struct PitchColorPaletteImage: View {
    public let pitchColorPalette: PitchColorPalette
    
    public init(pitchColorPalette: PitchColorPalette) {
        self.pitchColorPalette = pitchColorPalette
    }
    
    public var body: some View {
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

