// Models/PitchColorPalette+SystemData.swift

import Foundation
import SwiftData
import SwiftUI

extension PitchColorPalette: SystemSeedable {
    public static func fetchDescriptor(systemID: String) -> FetchDescriptor<PitchColorPalette> {
        FetchDescriptor<PitchColorPalette>(
            predicate: #Predicate { $0.systemIdentifier == systemID }
        )
    }
}

@MainActor
extension PitchColorPalette {
    // Default key colors
    public static let whiteKeys = RGBAColor(.white)
    public static let blackKeys = RGBAColor(.systemGray4)
    public static let redKeys   = RGBAColor(
        red:   1.0,
        green: 1.0929838e-06,
        blue:  1.03481085e-07,
        alpha: 1.0
    )

    // System IDs
    private static let ivoryID = "Ivory-System-Pitch-Palette-0001"
    private static let ebonyID = "Ebony-System-Pitch-Palette-0002"

    // Ephemeral definitions for seeding
    private static let definitions: [(id: String, factory: (ModelContext) -> PitchColorPalette)] = [
        (
            ivoryID,
            { ctx in
                PitchColorPalette(
                    systemIdentifier: ivoryID,
                    name: "Ivory",
                    position: 1,
                    naturalRGBAColor: whiteKeys,
                    accidentalRGBAColor: blackKeys,
                    outlineRGBAColor: redKeys
                )
            }
        ),
        (
            ebonyID,
            { ctx in
                PitchColorPalette(
                    systemIdentifier: ebonyID,
                    name: "Ebony",
                    position: 2,
                    naturalRGBAColor: blackKeys,
                    accidentalRGBAColor: whiteKeys,
                    outlineRGBAColor: redKeys
                )
            }
        )
    ]

    /// Seed both built‑in palettes into the given context.
    public static func seedSystemPalettes(in context: ModelContext) {
        context.seedSystemEntities(
            definitions: definitions
        ) { _, _ in
            // no static vars to reassign
        }
    }

    /// Fetch the “Ivory” palette from the given context.
    @MainActor
    public static func ivory(in context: ModelContext) -> PitchColorPalette {
        context.systemEntity(of: PitchColorPalette.self, id: ivoryID)
    }

    /// Fetch the “Ebony” palette from the given context.
    @MainActor
    public static func ebony(in context: ModelContext) -> PitchColorPalette {
        context.systemEntity(of: PitchColorPalette.self, id: ebonyID)
    }
}
