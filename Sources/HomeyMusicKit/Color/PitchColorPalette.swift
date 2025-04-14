import Foundation
import SwiftData
import SwiftUI

@Model
public final class PitchColorPalette: ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) public var id: UUID = UUID()
    @Attribute(.unique) public var systemIdentifier: String?
    public var name: String
    public var position: Int
    
    var naturalRGBAColor: RGBAColor
    var accidentalRGBAColor: RGBAColor
    var outlineRGBAColor: RGBAColor
    
    // MARK: - Init
    @MainActor
    init(
        systemIdentifier: String? = nil,
        name: String,
        position: Int,
        naturalRGBAColor: RGBAColor = PitchColorPalette.whiteKeys,
        accidentalRGBAColor: RGBAColor = PitchColorPalette.blackKeys,
        outlineRGBAColor: RGBAColor = PitchColorPalette.redKeys
    ) {
        self.systemIdentifier = systemIdentifier
        self.name = name
        self.position = position
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
        outlineColor
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

