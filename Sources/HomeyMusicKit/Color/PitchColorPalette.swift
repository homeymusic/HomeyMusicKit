import Foundation
import SwiftData
import SwiftUI

@Model
public final class PitchColorPalette: ColorPalette {
    
    // MARK: - Basic Info
    public var name: String
    public var position: Int
    public var isSystemPalette: Bool
    
    var naturalRGBAColor: RGBAColor
    var accidentalRGBAColor: RGBAColor
    var outlineRGBAColor: RGBAColor
    
    // MARK: - Init
    @MainActor
    init(
        name: String,
        position: Int,
        isSystemPalette: Bool = false,
        naturalRGBAColor: RGBAColor = PitchColorPalette.ivoryNaturalColor,
        accidentalRGBAColor: RGBAColor = PitchColorPalette.ivoryAccidentalColor,
        outlineRGBAColor: RGBAColor = PitchColorPalette.ivoryOutlineColor
    ) {
        self.name = name
        self.position = position
        self.isSystemPalette = isSystemPalette
        self.naturalRGBAColor = naturalRGBAColor
        self.accidentalRGBAColor = accidentalRGBAColor
        self.outlineRGBAColor = outlineRGBAColor
    }
    
    public func majorMinorColor(majorMinor: MajorMinor) -> Color {
        switch majorMinor {
        case .major:
            return naturalColor
        case .neutral:
            return naturalColor
        case .minor:
            return accidentalColor
        }
    }
    
    public func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        inactiveColor(isNatural: isNatural).adjust(
            brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
        )
    }
    
    public func inactiveColor(isNatural: Bool) -> Color {
        if isNatural {
            return naturalColor
        } else {
            return accidentalColor
        }
    }
    
    public func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        inactiveTextColor(majorMinor: majorMinor, isNatural: isNatural).adjust(
            brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
        )
    }
    
    public func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        if isNatural {
            return accidentalColor
        } else {
            return naturalColor
        }
    }
    
    public func activeOutlineColor(majorMinor: MajorMinor) -> Color {
        inactiveOutlineColor(majorMinor: majorMinor).adjust(brightness: -0.2)
    }
    
    public func inactiveOutlineColor(majorMinor: MajorMinor) -> Color {
        outlineColor
    }
    
    public var benignColor: Color {
        naturalColor
    }
    
    public var accidentalColor: Color {
        get {
            Color(accidentalRGBAColor)
        }
        
        set {
            accidentalRGBAColor = RGBAColor(newValue)
        }
    }
    
    public var naturalColor: Color {
        get {
            Color(naturalRGBAColor)
        }
        
        set {
            naturalRGBAColor = RGBAColor(newValue)
        }
    }
    
    public var outlineColor: Color {
        get {
            Color(outlineRGBAColor)
        }
        
        set {
            outlineRGBAColor = RGBAColor(newValue)
        }
    }
}

