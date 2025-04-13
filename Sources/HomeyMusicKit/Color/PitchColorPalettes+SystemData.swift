import Foundation
import SwiftData

@MainActor
extension PitchColorPalette {
    public static let whiteKeys = RGBAColor(.white)
    public static let blackKeys = RGBAColor(.systemGray4)
    public static let redKeys = RGBAColor(.red)

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

    public static let gritty = PitchColorPalette(
        name: "Gritty",
        position: 4,
        isSystemPalette: false,
        naturalRGBAColor: RGBAColor(red: 0, green: 0.4621462226, blue: 0.714210093, alpha: 1.0),
        accidentalRGBAColor: RGBAColor(red: 0.6886785626, green: 0.7186159492, blue: 0.735288918, alpha: 1),
        outlineRGBAColor: RGBAColor(.white)
    )

    public static func seedSystemPitchPalettes(
        modelContext: ModelContext
    ) {
        [ivory, ebony, gritty].forEach { systemPitchColorPalette in
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
