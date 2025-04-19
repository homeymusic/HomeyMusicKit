// Models/IntervalColorPalette+SystemData.swift

import Foundation
import SwiftData

extension IntervalColorPalette: SystemSeedable {
    public static func fetchDescriptor(systemID: String) -> FetchDescriptor<IntervalColorPalette> {
        FetchDescriptor<IntervalColorPalette>(
            predicate: #Predicate { $0.systemIdentifier == systemID }
        )
    }
}

@MainActor
extension IntervalColorPalette {
    // Default colors
    public static let homeyMinorColor   = RGBAColor(red: 0.3647, green: 0.6784, blue: 0.9255, alpha: 1.0)
    public static let homeyNeutralColor = RGBAColor(red: 0.9529, green: 0.8667, blue: 0.6706, alpha: 1.0)
    public static let homeyMajorColor   = RGBAColor(red: 1.0,    green: 0.6745, blue: 0.2,    alpha: 1.0)
    public static let homeyBaseColor    = RGBAColor(red: 0.4,    green: 0.2667, blue: 0.2,    alpha: 1.0)
    public static let starryBaseColor   = RGBAColor(red: 0.2,    green: 0.2,    blue: 0.2,    alpha: 1.0)

    // System IDs
    private static let homeyID  = "Homey-System-Interval-Palette-0001"
    private static let starryID = "Starry-System-Interval-Palette-0002"

    // Ephemeral definitions for seeding
    private static let definitions: [(id: String, factory: (ModelContext) -> IntervalColorPalette)] = [
        (
            homeyID,
            { ctx in
                IntervalColorPalette(
                    systemIdentifier: homeyID,
                    name: "Homey",
                    position: 1,
                    minorRGBAColor: homeyMinorColor,
                    neutralRGBAColor: homeyNeutralColor,
                    majorRGBAColor: homeyMajorColor,
                    cellBackgroundRGBAColor: homeyBaseColor
                )
            }
        ),
        (
            starryID,
            { ctx in
                IntervalColorPalette(
                    systemIdentifier: starryID,
                    name: "Starry",
                    position: 2,
                    minorRGBAColor: homeyMinorColor,
                    neutralRGBAColor: homeyNeutralColor,
                    majorRGBAColor: homeyMajorColor,
                    cellBackgroundRGBAColor: starryBaseColor
                )
            }
        )
    ]

    /// Seed both built‑in palettes into this context.
    public static func seedSystemPalettes(in context: ModelContext) {
        context.seedSystemEntities(
            definitions: definitions
        ) { _, _ in
            // no static vars to reassign
        }
    }

    /// Fetch the “Homey” palette from this context.
    public static func homey(in context: ModelContext) -> IntervalColorPalette {
        context.systemEntity(of: IntervalColorPalette.self, id: homeyID)
    }

    /// Fetch the “Starry” palette from this context.
    public static func starry(in context: ModelContext) -> IntervalColorPalette {
        context.systemEntity(of: IntervalColorPalette.self, id: starryID)
    }
}
