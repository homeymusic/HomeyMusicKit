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
    
    public static let motorCity = IntervalColorPalette(
        name: "City",
        position: 2,
        isSystemPalette: false,
        minorRGBAColor: RGBAColor(red: 0.19615265727043152, green: 0.7796291708946228, blue: 0.34923413395881653, alpha: 1.0),
        neutralRGBAColor: RGBAColor(red: 1.000000238418579, green: 1.0929837799267261e-06, blue: 1.0348108503421827e-07, alpha: 1.0),
        majorRGBAColor: RGBAColor(red: 1.0002332925796509, green: 0.8001158833503723, blue: 0.006338595878332853, alpha: 1.0),
        cellBackgroundRGBAColor: RGBAColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    )
    
    public static let country = IntervalColorPalette(
        name: "Country",
        position: 3,
        isSystemPalette: false,
        minorRGBAColor: RGBAColor(red: 0.400, green: 0.498, blue: 0.702, alpha: 1.0),
        neutralRGBAColor: RGBAColor(red: 0.9490, green: 0.9412, blue: 0.9020, alpha: 1.0),
        majorRGBAColor: RGBAColor(red: 0.937, green: 0.843, blue: 0.451, alpha: 1.0),
        cellBackgroundRGBAColor: RGBAColor(red: 0.1059, green: 0.2275, blue: 0.1059, alpha: 1.0)
    )
    
    public static func seedSystemIntervalPalettes(
        modelContext: ModelContext
    ) {
        [homey, motorCity, country].forEach { systemIntervalColorPalette in
            let systemPaletteName = systemIntervalColorPalette.name
            let fetchDescriptor = FetchDescriptor<IntervalColorPalette>(
                predicate: #Predicate { palette in
                    palette.name == systemPaletteName
                }
            )
            
            // Try to fetch any existing palettes matching this criteria.
            if let results = try? modelContext.fetch(fetchDescriptor), results.isEmpty {
                modelContext.insert(systemIntervalColorPalette)
            }
        }
    }
}
