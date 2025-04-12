import Foundation
import SwiftData

@MainActor
extension PitchColorPalette {
    public static let ivoryNaturalColor = RGBAColor(.white)
    public static let ivoryAccidentalColor = RGBAColor(.systemGray4)
    public static let ivoryOutlineColor = RGBAColor(.red)

    static let ebony = PitchColorPalette(
        name: "Ebony",
        position: 1,
        isSystemPalette: true,
        naturalRGBAColor: PitchColorPalette.ivoryAccidentalColor,
        accidentalRGBAColor: PitchColorPalette.ivoryNaturalColor,
        outlineRGBAColor: PitchColorPalette.ivoryOutlineColor
    )
    
    static let ivory = PitchColorPalette(
        name: "Ivory",
        position: 2,
        isSystemPalette: true,
        naturalRGBAColor: PitchColorPalette.ivoryNaturalColor,
        accidentalRGBAColor: PitchColorPalette.ivoryAccidentalColor,
        outlineRGBAColor: PitchColorPalette.ivoryOutlineColor
    )
    
    public static func seedSystemPitchPalettes(
        modelContext: ModelContext
    ) {
        [ebony, ivory].forEach { systemPitchColorPalette in
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
