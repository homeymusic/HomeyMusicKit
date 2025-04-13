import Foundation
import SwiftData

@MainActor
extension PitchColorPalette {
    public static let whiteKeys = RGBAColor(.white)
    public static let blackKeys = RGBAColor(.systemGray4)
    public static let redKeys = RGBAColor(red: 1.000000238418579, green: 1.0929837799267261e-06, blue: 1.0348108503421827e-07, alpha: 1.0)
    public static let cyanKeys = RGBAColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public static let yellowKeys = RGBAColor(red: 1.0002332925796509, green: 0.8001158833503723, blue: 0.006338595878332853, alpha: 1.0)

    static let ivory = PitchColorPalette(
        name: "Ivory",
        position: 1,
        isSystemPalette: true,
        naturalRGBAColor: PitchColorPalette.whiteKeys,
        accidentalRGBAColor: PitchColorPalette.blackKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )
    
    static let ebony = PitchColorPalette(
        name: "Ebony",
        position: 2,
        isSystemPalette: false,
        naturalRGBAColor: PitchColorPalette.blackKeys,
        accidentalRGBAColor: PitchColorPalette.whiteKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )

    static let stripy = PitchColorPalette(
        name: "Stripy",
        position: 3,
        isSystemPalette: false,
        naturalRGBAColor: PitchColorPalette.redKeys,
        accidentalRGBAColor: RGBAColor(.white),
        outlineRGBAColor: PitchColorPalette.yellowKeys
    )


    public static func seedSystemPitchPalettes(
        modelContext: ModelContext
    ) {
        [ivory, ebony, stripy].forEach { systemPitchColorPalette in
            let systemPaletteName = systemPitchColorPalette.name
            let fetchDescriptor = FetchDescriptor<PitchColorPalette>(
                predicate: #Predicate { palette in
                    palette.name == systemPaletteName
                }
            )
            
            // Try to fetch any existing palettes matching this criteria.
            if let results = try? modelContext.fetch(fetchDescriptor), results.isEmpty {
                modelContext.insert(systemPitchColorPalette)
            }
        }
    }
}
