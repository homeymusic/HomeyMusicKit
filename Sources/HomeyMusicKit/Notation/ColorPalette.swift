import Foundation
import SwiftData
import SwiftUI

@Model
public final class ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) var name: String
    var paletteType: PaletteType
    var isSystemPalette: Bool
    
    // MARK: - .movable colors
    var baseRGBAColor: RGBAColor?
    var majorRGBAColor: RGBAColor?
    var neutralRGBAColor: RGBAColor?
    var minorRGBAColor: RGBAColor?

    
    // MARK: - .fixed colors
    var accidentalRGBAColor: RGBAColor?
    var naturalRGBAColor: RGBAColor?
    var outlineRGBAColor: RGBAColor?
    
    // MARK: - Init
    init(
        name: String,
        paletteType: PaletteType,
        isSystemPalette: Bool = false,
        baseRGBAColor: RGBAColor? = nil,
        majorRGBAColor: RGBAColor? = nil,
        neutralRGBAColor: RGBAColor? = nil,
        minorRGBAColor: RGBAColor? = nil,
        accidentalRGBAColor: RGBAColor? = nil,
        naturalRGBAColor: RGBAColor? = nil,
        outlineRGBAColor: RGBAColor? = nil
    ) {
        self.name = name
        self.paletteType = paletteType
        self.isSystemPalette = isSystemPalette
        self.baseRGBAColor = baseRGBAColor
        self.majorRGBAColor = majorRGBAColor
        self.neutralRGBAColor = neutralRGBAColor
        self.minorRGBAColor = minorRGBAColor
        self.accidentalRGBAColor = accidentalRGBAColor
        self.naturalRGBAColor = naturalRGBAColor
        self.outlineRGBAColor = outlineRGBAColor
    }
    
    var baseColor: Color {
        get {
            if (baseRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(baseRGBAColor!)
            }
        }
        
        set {
            baseRGBAColor = RGBAColor(newValue)
        }
    }
    
    var majorColor: Color {
        get {
            if (majorRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(majorRGBAColor!)
            }
        }
        
        set {
            majorRGBAColor = RGBAColor(newValue)
        }
    }
    
    var neutralColor: Color {
        get {
            if (neutralRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(neutralRGBAColor!)
            }
        }
        
        set {
            neutralRGBAColor = RGBAColor(newValue)
        }
    }
    
    var minorColor: Color {
        get {
            if (minorRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(minorRGBAColor!)
            }
        }
        
        set {
            minorRGBAColor = RGBAColor(newValue)
        }
    }
    
    var accidentalColor: Color {
        get {
            if (accidentalRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(accidentalRGBAColor!)
            }
        }
        
        set {
            accidentalRGBAColor = RGBAColor(newValue)
        }
    }
    
    var naturalColor: Color {
        get {
            if (naturalRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(naturalRGBAColor!)
            }
        }
        
        set {
            naturalRGBAColor = RGBAColor(newValue)
        }
    }
    
    var outlineColor: Color {
        get {
            if (outlineRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(outlineRGBAColor!)
            }
        }
        
        set {
            outlineRGBAColor = RGBAColor(newValue)
        }
    }
}

extension ColorPalette {
    enum PaletteType: String, CaseIterable, Codable {
        case fixed = "fixed"
        case movable = "movable"
    }
}
