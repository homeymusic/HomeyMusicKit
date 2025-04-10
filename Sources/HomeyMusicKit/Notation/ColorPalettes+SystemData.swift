import Foundation
import SwiftData

@MainActor
extension ColorPalette {

    public static let homey = ColorPalette(
        name: HomeyMusicKit.defaultColorPaletteName,
        intervalPosition: 1,
        paletteType: .interval,
        isSystemPalette: true,
        baseRGBAColor: RGBAColor(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1),
        majorRGBAColor: RGBAColor(red: 1, green: 0.6745098039, blue: 0.2, alpha: 1.0),
        neutralRGBAColor: RGBAColor(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1.0),
        minorRGBAColor: RGBAColor(red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, alpha: 1.0)
    )
    static let ebonyIvory = ColorPalette(
        name: "Ebony & Ivory",
        pitchPosition: 1,
        paletteType: .pitch,
        isSystemPalette: true,
        accidentalRGBAColor: RGBAColor(.systemGray4),
        naturalRGBAColor: RGBAColor(.white),
        outlineRGBAColor: RGBAColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    )

    public static func seedSystemData(
        modelContext: ModelContext
    ) {
        let systemPalettes: [ColorPalette] = [homey, ebonyIvory]
      
        for systemPalette in systemPalettes {
            // Create a fetch descriptor that finds a system palette with the given name.
            // (Adjust the predicate syntax if needed for your version of SwiftData.)
            let systemPaletteName = systemPalette.name
            let fetchDescriptor = FetchDescriptor<ColorPalette>(
                predicate: #Predicate { palette in
                    palette.name == systemPaletteName
                }
            )
            
            // Try to fetch any existing palettes matching this criteria.
            if let results = try? modelContext.fetch(fetchDescriptor), results.isEmpty {
                modelContext.insert(systemPalette)
            }
        }
    }
}
