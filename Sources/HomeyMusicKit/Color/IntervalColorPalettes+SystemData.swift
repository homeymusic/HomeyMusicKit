import Foundation
import SwiftData

@MainActor
extension IntervalColorPalette {
    public static let homeyMinorColor = RGBAColor(red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, alpha: 1.0)
    public static let homeyNeutralColor = RGBAColor(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1.0)
    public static let homeyMajorColor = RGBAColor(red: 1, green: 0.6745098039, blue: 0.2, alpha: 1.0)
    public static let homeyBaseColor = RGBAColor(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1)

    public static let homey = IntervalColorPalette(
        name: "Homey",
        position: 1,
        isSystemPalette: true,
        minorRGBAColor: IntervalColorPalette.homeyMinorColor,
        neutralRGBAColor: IntervalColorPalette.homeyNeutralColor,
        majorRGBAColor: IntervalColorPalette.homeyMajorColor,
        cellBackgroundRGBAColor: IntervalColorPalette.homeyBaseColor
    )
    
    public static func seedSystemIntervalPalettes(
        modelContext: ModelContext
    ) {
        let systemPaletteName = homey.name

        let fetchDescriptor = FetchDescriptor<IntervalColorPalette>(
            predicate: #Predicate { palette in
                palette.name == systemPaletteName
            }
        )
        
        // Try to fetch any existing palettes matching this criteria.
        if let results = try? modelContext.fetch(fetchDescriptor), results.isEmpty {
            modelContext.insert(homey)
        }
    }
}
