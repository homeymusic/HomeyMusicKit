import Foundation
import SwiftData

@MainActor
extension IntervalColorPalette {
    // For convenience, define your default colors:
    public static let homeyMinorColor = RGBAColor(red: 0.3647, green: 0.6784, blue: 0.9255, alpha: 1.0)
    public static let homeyNeutralColor = RGBAColor(red: 0.9529, green: 0.8667, blue: 0.6706, alpha: 1.0)
    public static let homeyMajorColor = RGBAColor(red: 1.0,    green: 0.6745, blue: 0.2,    alpha: 1.0)
    public static let homeyBaseColor  = RGBAColor(red: 0.4,    green: 0.2667, blue: 0.2,    alpha: 1.0)
    
    // A hidden ID you never expose in UI
    private static let homeySystemID = "Homey-System-IntervalPalette"

    public static var homey = IntervalColorPalette(
        systemIdentifier: IntervalColorPalette.homeySystemID,
        name: "Homey",
        position: 1,
        isSystemPalette: true,
        minorRGBAColor: homeyMinorColor,
        neutralRGBAColor: homeyNeutralColor,
        majorRGBAColor: homeyMajorColor,
        cellBackgroundRGBAColor: homeyBaseColor
    )
    
    // Repeat for other built-in palettes:
    private static let detroitSystemID = "Detroit-System-IntervalPalette"
    private static let corktownSystemID = "Corktown-System-IntervalPalette"

    public static var detroit = IntervalColorPalette(
        systemIdentifier: detroitSystemID,
        name: "City",
        position: 2,
        isSystemPalette: false,
        minorRGBAColor: RGBAColor(red: 0.1961, green: 0.7796, blue: 0.3492, alpha: 1.0),
        neutralRGBAColor: RGBAColor(red: 1.0,    green: 0.0,    blue: 0.0,    alpha: 1.0),
        majorRGBAColor: RGBAColor(red: 1.0,    green: 0.8,    blue: 0.0063, alpha: 1.0),
        cellBackgroundRGBAColor: RGBAColor(red: 0.2,   green: 0.2,   blue: 0.2,   alpha: 1.0)
    )

    public static var corktown = IntervalColorPalette(
        systemIdentifier: corktownSystemID,
        name: "Country",
        position: 3,
        isSystemPalette: false,
        minorRGBAColor: RGBAColor(red: 0.400, green: 0.498, blue: 0.702, alpha: 1.0),
        neutralRGBAColor: RGBAColor(red: 0.9490, green: 0.9412, blue: 0.9020, alpha: 1.0),
        majorRGBAColor: RGBAColor(red: 0.922, green: 0.518, blue: 0.227, alpha: 1.0),
        cellBackgroundRGBAColor: RGBAColor(red: 0.1059, green: 0.2275, blue: 0.1059, alpha: 1.0)
    )

    // Seeding function
    public static func seedSystemIntervalPalettes(modelContext: ModelContext, notationalContext: NotationalContext) {
        let allSystemPalettes = [homey, detroit, corktown]
        
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
                case IntervalColorPalette.detroitSystemID:
                    IntervalColorPalette.detroit = existing
                case IntervalColorPalette.corktownSystemID:
                    IntervalColorPalette.corktown = existing
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
