import Foundation
import SwiftData

@Model
public final class ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) var name: String
    var paletteType: PaletteType
    var isSystemPalette: Bool

    
    // MARK: - Init
    init(
        name: String,
        paletteType: PaletteType,
        isSystemPalette: Bool = false,
    ) {
        self.name = name
        self.paletteType = paletteType
        self.isSystemPalette = isSystemPalette
    }
}

extension ColorPalette {
    enum PaletteType: String, CaseIterable, Codable {
        case fixed = "fixed"
        case movable = "movable"
    }
}
