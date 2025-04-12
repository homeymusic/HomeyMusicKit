import Foundation
import SwiftData


@MainActor
extension ColorPalette {
    public static let homeyBaseColor = RGBAColor(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1)
    public static let homeyMajorColor = RGBAColor(red: 1, green: 0.6745098039, blue: 0.2, alpha: 1.0)
    public static let homeyNeutralColor = RGBAColor(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1.0)
    public static let homeyMinorColor = RGBAColor(red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, alpha: 1.0)
    
    public static let ebonyIvoryNaturalColor = RGBAColor(.white)
    public static let ebonyIvoryAccidentalColor = RGBAColor(.systemGray4)
    public static let ebonyIvoryOutlineColor = RGBAColor(.red)

    public static let homey = ColorPalette(
        name: "Homey",
        intervalPosition: 1,
        paletteType: .interval,
        isSystemPalette: true,
        baseRGBAColor: homeyBaseColor,
        majorRGBAColor: homeyMajorColor,
        neutralRGBAColor: homeyNeutralColor,
        minorRGBAColor:homeyMinorColor
    )
    static let ebonyIvory = ColorPalette(
        name: "Ebony & Ivory",
        pitchPosition: 1,
        paletteType: .pitch,
        isSystemPalette: true,
        accidentalRGBAColor: ebonyIvoryAccidentalColor,
        naturalRGBAColor: ebonyIvoryNaturalColor,
        outlineRGBAColor: ebonyIvoryOutlineColor
    )

    static let systemPalettes: [ColorPalette] = [homey, ebonyIvory]
    
    public static func seedSystemData(
        modelContext: ModelContext
    ) {
      
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
