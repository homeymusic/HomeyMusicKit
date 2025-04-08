import Foundation
import SwiftData
import SwiftUI

@Model
public final class ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) var name: String
    @Attribute(.unique) var position: Int
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
        position: Int,
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
        self.position = position
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
    
    private func majorMinorColor(majorMinor: MajorMinor) -> Color {
        switch majorMinor {
        case .major:
            return majorColor
        case .neutral:
            return neutralColor
        case .minor:
            return minorColor
        }
    }
    
    func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .movable:
            return majorMinorColor(majorMinor: majorMinor)
        case .fixed:
            return inactiveColor(isNatural: isNatural).adjust(
                brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
            )
        }
    }
    
    func inactiveColor(isNatural: Bool) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            if isNatural {
                return naturalColor
            } else {
                return accidentalColor
            }
        }
    }
    
    func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            return inactiveTextColor(majorMinor: majorMinor, isNatural: isNatural).adjust(
                brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
            )
        }
    }
    
    func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .movable:
            return majorMinorColor(majorMinor: majorMinor)
        case .fixed:
            if isNatural {
                return accidentalColor
            } else {
                return naturalColor
            }
        }
    }
    
    func activeOutlineColor(majorMinor: MajorMinor) -> Color {
        switch paletteType {
        case .movable:
            return baseColor
        case .fixed:
            return inactiveOutlineColor(majorMinor: majorMinor).adjust(brightness: -0.2)
        }
    }
    
    func inactiveOutlineColor(majorMinor: MajorMinor) -> Color {
        switch paletteType {
        case .movable:
            return majorMinorColor(majorMinor: majorMinor)
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
        case movable = "interval palette"
        case fixed = "pitch palette"
    }
}

extension ColorPalette: Identifiable {
    public var id: String {
        // Because name is unique in your model, use it as the ID
        name
    }
}
