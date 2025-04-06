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
    
    func activeColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            switch pitch.majorMinor(for: tonalContext) {
            case .major:
                return majorColor
            case .neutral:
                return neutralColor
            case .minor:
                return minorColor
            }
        case .fixed:
            return inactiveColor(pitch: pitch, tonalContext: tonalContext).adjust(brightness: -0.2)
        }
    }
    
    func inactiveColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            if pitch.isNatural {
                return naturalColor
            } else {
                return accidentalColor
            }
        }
    }
    
    func activeTextColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            return inactiveTextColor(pitch: pitch, tonalContext: tonalContext).adjust(brightness: -0.2)
        }
    }
    
    func inactiveTextColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            switch pitch.majorMinor(for: tonalContext) {
            case .major:
                return majorColor
            case .neutral:
                return neutralColor
            case .minor:
                return minorColor
            }
        case .fixed:
            if pitch.isNatural {
                return accidentalColor
            } else {
                return naturalColor
            }
        }
    }
    
    func activeOutlineColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            return inactiveOutlineColor(pitch: pitch, tonalContext: tonalContext).adjust(brightness: -0.2)
        }
    }
    
    func inactiveOutlineColor(pitch: Pitch, tonalContext: TonalContext) -> Color {
        switch paletteType {
        case .movable:
            switch pitch.majorMinor(for: tonalContext) {
            case .major:
                return majorColor
            case .neutral:
                return neutralColor
            case .minor:
                return minorColor
            }
        case .fixed:
            return outlineColor
        }
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
