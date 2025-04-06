import Foundation
import SwiftData

@MainActor
extension ColorPalette {

    static let defaultName = "Homey"
    public static let homey = ColorPalette(
        name: defaultName,
        paletteType: .movable,
        isSystemPalette: true,
        baseRGBAColor: RGBAColor(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1)        
    )
    static let homey2 = ColorPalette(name: "Homey 2", paletteType: .movable, isSystemPalette: true)
    static let homey3 = ColorPalette(name: "Homey 3", paletteType: .movable, isSystemPalette: true)
    static let ebonyIvory = ColorPalette(name: "Ebony & Ivory", paletteType: .fixed, isSystemPalette: true)
    static let ebonyIvory2 = ColorPalette(name: "Ebony & Ivory 2", paletteType: .fixed, isSystemPalette: true)
    static let ebonyIvory3 = ColorPalette(name: "Ebony & Ivory 3", paletteType: .fixed, isSystemPalette: true)

    public static func seedSystemData(
        modelContext: ModelContext
    ) {        
        let systemPalettes: [ColorPalette] = [homey, ebonyIvory, homey2, ebonyIvory2, homey3, ebonyIvory3]
      
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
