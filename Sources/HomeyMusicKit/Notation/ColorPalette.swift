import Foundation
import SwiftData
import SwiftUI

@Model
public final class ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) var name: String
    @Attribute(.unique) var intervalPosition: Int?
    @Attribute(.unique) var pitchPosition: Int?
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
        intervalPosition: Int? = nil,
        pitchPosition: Int? = nil,
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
        self.intervalPosition = intervalPosition
        self.pitchPosition = pitchPosition
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
            return baseColor
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
            return baseColor
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
            return baseColor
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
    public enum PaletteType: String, CaseIterable, Codable {
        case interval = "interval palette"
        case pitch = "pitch palette"
    }
}

extension ColorPalette: Identifiable {
    public var id: String {
        // Because name is unique in your model, use it as the ID
        name
    }
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
