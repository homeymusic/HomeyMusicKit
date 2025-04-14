import Foundation
import SwiftData
import SwiftUI

@MainActor
extension PitchColorPalette {
    // Example default RGBAColors (from your code).
    public static let whiteKeys = RGBAColor(.white)
    public static let blackKeys = RGBAColor(.systemGray4)
    public static let redKeys   = RGBAColor(
        red: 1.0,
        green: 1.0929838e-06,
        blue: 1.03481085e-07,
        alpha: 1.0
    )
    
    private static let ivorySystemID   = "Ivory-System-Pitch-Palette-0001"
    public static var ivory = PitchColorPalette(
        systemIdentifier: ivorySystemID,
        name: "Ivory",
        position: 1,
        naturalRGBAColor: PitchColorPalette.whiteKeys,
        accidentalRGBAColor: PitchColorPalette.blackKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )
    
    private static let ebonySystemID   = "Ebony-System-Pitch-Palette-0002"
    public static var ebony = PitchColorPalette(
        systemIdentifier: ebonySystemID,
        name: "Ebony",
        position: 2,
        naturalRGBAColor: PitchColorPalette.blackKeys,
        accidentalRGBAColor: PitchColorPalette.whiteKeys,
        outlineRGBAColor: PitchColorPalette.redKeys
    )
    
    public static func seedSystemPitchPalettes(modelContext: ModelContext) {
        let allSystemPalettes = [ivory, ebony]
        
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
