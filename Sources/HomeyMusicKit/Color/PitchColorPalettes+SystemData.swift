import Foundation
import SwiftData
import SwiftUI

@MainActor
extension PitchColorPalette {
    // Example default RGBAColors (from your code).
    public static let whiteKeys = RGBAColor(.white)
    public static let blackKeys = RGBAColor(.systemGray4)
    public static let redKeys   = RGBAColor(red: 1.0,
                                            green: 1.0929838e-06,
                                            blue: 1.03481085e-07,
                                            alpha: 1.0)
    public static let cyanKeys  = RGBAColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public static let yellowKeys = RGBAColor(red: 1.0002333,
                                             green: 0.80011588,
                                             blue: 0.00633859,
                                             alpha: 1.0)

    // 1) Hidden system identifiers for each system palette
    private static let ivorySystemID   = "PitchPalette-Ivory-1234"
    private static let ebonySystemID   = "PitchPalette-Ebony-5678"
    private static let stripeySystemID = "PitchPalette-Stripey-9999"

    // 2) Define the ephemeral static palettes with those IDs
    public static var ivory = PitchColorPalette(
        systemIdentifier: ivorySystemID,
        name: "Ivory",
        position: 1,
        isSystemPalette: true,
        naturalRGBAColor: PitchColorPalette.whiteKeys,
        accidentalRGBAColor: PitchColorPalette.blackKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )
    
    public static var ebony = PitchColorPalette(
        systemIdentifier: ebonySystemID,
        name: "Ebony",
        position: 2,
        // For demonstration, it's "isSystemPalette: false,"
        // but we're still giving it a systemIdentifier to unify it.
        isSystemPalette: false,
        naturalRGBAColor: PitchColorPalette.blackKeys,
        accidentalRGBAColor: PitchColorPalette.whiteKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )

    public static var whiteStripes = PitchColorPalette(
        systemIdentifier: stripeySystemID,
        name: "Stripey",
        position: 3,
        isSystemPalette: false,
        naturalRGBAColor: PitchColorPalette.redKeys,
        accidentalRGBAColor: PitchColorPalette.whiteKeys,
        outlineRGBAColor: PitchColorPalette.blackKeys
    )

    // 3) Seeding function using systemIdentifier
    public static func seedSystemPitchPalettes(modelContext: ModelContext) {
        let allSystemPalettes = [ivory, ebony, whiteStripes]
        
        for palette in allSystemPalettes {
            // Unwrap the systemIdentifier
            guard let sysID = palette.systemIdentifier else { continue }

            // Build a fetch descriptor to find any existing palette with that ID
            let fetchDescriptor = FetchDescriptor<PitchColorPalette>(
                predicate: #Predicate { $0.systemIdentifier == sysID }
            )
            
            // Attempt to fetch
            guard let results = try? modelContext.fetch(fetchDescriptor) else { continue }

            if let existing = results.first {
                // Already have one in the store => unify the static var
                switch sysID {
                case ivorySystemID:
                    PitchColorPalette.ivory = existing
                case ebonySystemID:
                    PitchColorPalette.ebony = existing
                case stripeySystemID:
                    PitchColorPalette.whiteStripes = existing
                default:
                    break
                }
            } else {
                // Not found => insert the ephemeral object
                modelContext.insert(palette)
                // The static var already refers to 'palette', so no further action needed
            }
        }
    }
}
