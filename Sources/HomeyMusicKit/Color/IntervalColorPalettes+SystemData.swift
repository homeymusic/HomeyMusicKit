import Foundation
import SwiftData

@MainActor
extension IntervalColorPalette {
    public static let homeyMinorColor = RGBAColor(red: 0.3647, green: 0.6784, blue: 0.9255, alpha: 1.0)
    public static let homeyNeutralColor = RGBAColor(red: 0.9529, green: 0.8667, blue: 0.6706, alpha: 1.0)
    public static let homeyMajorColor = RGBAColor(red: 1.0,    green: 0.6745, blue: 0.2,    alpha: 1.0)
    public static let homeyBaseColor  = RGBAColor(red: 0.4,    green: 0.2667, blue: 0.2,    alpha: 1.0)
    public static let starryBaseColor = RGBAColor(red: 0.2,   green: 0.2,   blue: 0.2,   alpha: 1.0)
    
    // A hidden ID you never expose in UI
    private static let homeySystemID = "Homey-System-Interval-Palette-0001"
    public static var homey = IntervalColorPalette(
        systemIdentifier: IntervalColorPalette.homeySystemID,
        name: "Homey",
        position: 1,
        minorRGBAColor: homeyMinorColor,
        neutralRGBAColor: homeyNeutralColor,
        majorRGBAColor: homeyMajorColor,
        cellBackgroundRGBAColor: homeyBaseColor
    )
    
    private static let starrySystemID = "Starry-System-Interval-Palette-0002"
    public static var starry = IntervalColorPalette(
        systemIdentifier: starrySystemID,
        name: "Starry",
        position: 2,
        minorRGBAColor: homeyMinorColor,
        neutralRGBAColor: homeyNeutralColor,
        majorRGBAColor: homeyMajorColor,
        cellBackgroundRGBAColor: starryBaseColor
    )

    public static func seedSystemIntervalPalettes(modelContext: ModelContext) {
        let allSystemPalettes = [homey, starry]
        
        for systemPalette in allSystemPalettes {
            // Fetch by systemIdentifier instead of name:
            guard let sysID = systemPalette.systemIdentifier else { continue }
            
            let fetchDescriptor = FetchDescriptor<IntervalColorPalette>(
                predicate: #Predicate { $0.systemIdentifier == sysID }
            )
            
            // Try to fetch an existing palette with this systemIdentifier
            guard let results = try? modelContext.fetch(fetchDescriptor) else { continue }

            if let existing = results.first {
                // Already in the store => unify by pointing the static var to the store object
                switch sysID {
                case IntervalColorPalette.homeySystemID:
                    IntervalColorPalette.homey = existing
                case IntervalColorPalette.starrySystemID:
                    IntervalColorPalette.starry = existing
                default:
                    break
                }
            } else {
                // Insert the ephemeral object into the store
                modelContext.insert(systemPalette)
                // Keep the static var referencing it (since we just inserted it)
            }
        }
    }
}
