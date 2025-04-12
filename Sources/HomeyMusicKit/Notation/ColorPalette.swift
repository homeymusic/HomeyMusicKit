import Foundation
import SwiftData
import SwiftUI

@Model
public final class ColorPalette {
    
    // MARK: - Basic Info
    var name: String
    var intervalPosition: Int?
    var pitchPosition: Int?
    var paletteType: ColorPaletteType
    var paletteTypeRaw: Int
    var isSystemPalette: Bool
    
    // MARK: - .movable colors
    var cellBackgroundRGBAColor: RGBAColor?
    var majorRGBAColor: RGBAColor?
    var neutralRGBAColor: RGBAColor?
    var minorRGBAColor: RGBAColor?

    
    // MARK: - .fixed colors
    var accidentalRGBAColor: RGBAColor?
    var naturalRGBAColor: RGBAColor?
    var outlineRGBAColor: RGBAColor?
    
    // MARK: - Init
    @MainActor
    init(
        name: String = "",
        intervalPosition: Int? = nil,
        pitchPosition: Int? = nil,
        paletteType: ColorPaletteType,
        isSystemPalette: Bool = false,
        baseRGBAColor: RGBAColor? = homeyBaseColor,
        majorRGBAColor: RGBAColor? = homeyMajorColor,
        neutralRGBAColor: RGBAColor? = homeyNeutralColor,
        minorRGBAColor: RGBAColor? = homeyMinorColor,
        accidentalRGBAColor: RGBAColor? = ebonyIvoryAccidentalColor,
        naturalRGBAColor: RGBAColor? = ebonyIvoryNaturalColor,
        outlineRGBAColor: RGBAColor? = ebonyIvoryOutlineColor
    ) {
        self.name = name
        self.intervalPosition = intervalPosition
        self.pitchPosition = pitchPosition
        self.paletteType = paletteType
        self.paletteTypeRaw = paletteType.rawValue
        self.isSystemPalette = isSystemPalette
        self.cellBackgroundRGBAColor = baseRGBAColor
        self.majorRGBAColor = majorRGBAColor
        self.neutralRGBAColor = neutralRGBAColor
        self.minorRGBAColor = minorRGBAColor
        self.accidentalRGBAColor = accidentalRGBAColor
        self.naturalRGBAColor = naturalRGBAColor
        self.outlineRGBAColor = outlineRGBAColor
    }
    
    public func majorMinorColor(majorMinor: MajorMinor) -> Color {
        switch self.paletteType {
        case .interval:
            switch majorMinor {
            case .major:
                return majorColor
            case .neutral:
                return neutralColor
            case .minor:
                return minorColor
            }
        case .pitch:
            switch majorMinor {
            case .major:
                return naturalColor
            case .neutral:
                return naturalColor
            case .minor:
                return accidentalColor
            }
        }
    }
    
    func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .interval:
            return majorMinorColor(majorMinor: majorMinor)
        case .pitch:
            return inactiveColor(isNatural: isNatural).adjust(
                brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
            )
        }
    }
    
    func inactiveColor(isNatural: Bool) -> Color {
        switch paletteType {
        case .interval:
            return cellBackgroundColor
        case .pitch:
            if isNatural {
                return naturalColor
            } else {
                return accidentalColor
            }
        }
    }
    
    func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .interval:
            return cellBackgroundColor
        case .pitch:
            return inactiveTextColor(majorMinor: majorMinor, isNatural: isNatural).adjust(
                brightness: HomeyMusicKit.isActivatedBrightnessAdjustment
            )
        }
    }
    
    func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        switch paletteType {
        case .interval:
            return majorMinorColor(majorMinor: majorMinor)
        case .pitch:
            if isNatural {
                return accidentalColor
            } else {
                return naturalColor
            }
        }
    }
    
    func activeOutlineColor(majorMinor: MajorMinor) -> Color {
        switch paletteType {
        case .interval:
            return cellBackgroundColor
        case .pitch:
            return inactiveOutlineColor(majorMinor: majorMinor).adjust(brightness: -0.2)
        }
    }
    
    func inactiveOutlineColor(majorMinor: MajorMinor) -> Color {
        switch paletteType {
        case .interval:
            return majorMinorColor(majorMinor: majorMinor)
        case .pitch:
            return outlineColor
        }
    }
    
    var benignColor: Color {
        switch paletteType {
        case .interval:
            return neutralColor
        case .pitch:
            return naturalColor
        }
    }
    
    var cellBackgroundColor: Color {
        get {
            if (cellBackgroundRGBAColor == nil) {
                return Color.clear
            } else {
                return Color(cellBackgroundRGBAColor!)
            }
        }
        
        set {
            cellBackgroundRGBAColor = RGBAColor(newValue)
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

public enum ColorPaletteType: Int, CaseIterable, Codable {
    case interval = 0
    case pitch = 1
}

extension ColorPalette {
    public static func fetchColorPalette(colorPaletteName: String, modelContext: ModelContext) -> ColorPalette? {
        let descriptor = FetchDescriptor<ColorPalette>(
            predicate: #Predicate { palette in
                palette.name == colorPaletteName
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            // Handle or log error
            return nil
        }
    }

}
