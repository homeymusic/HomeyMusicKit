import Foundation
import SwiftData
import SwiftUI

@Model
public final class IntervalColorPalette: ColorPalette {
    
    // MARK: - Basic Info
    @Attribute(.unique) public var id: UUID = UUID()
    public var name: String
    public var position: Int
    public var isSystemPalette: Bool
    
    // MARK: - colors
    var minorRGBAColor: RGBAColor
    var neutralRGBAColor: RGBAColor
    var majorRGBAColor: RGBAColor
    var cellBackgroundRGBAColor: RGBAColor

    // MARK: - Init
    @MainActor
    init(
        name: String,
        position: Int,
        isSystemPalette: Bool = false,
        minorRGBAColor: RGBAColor = IntervalColorPalette.homeyMinorColor,
        neutralRGBAColor: RGBAColor = IntervalColorPalette.homeyNeutralColor,
        majorRGBAColor: RGBAColor = IntervalColorPalette.homeyMajorColor,
        cellBackgroundRGBAColor: RGBAColor = IntervalColorPalette.homeyBaseColor
    ) {
        self.name = name
        self.position = position
        self.isSystemPalette = isSystemPalette
        self.minorRGBAColor = minorRGBAColor
        self.neutralRGBAColor = neutralRGBAColor
        self.majorRGBAColor = majorRGBAColor
        self.cellBackgroundRGBAColor = cellBackgroundRGBAColor
    }
    
    public func majorMinorColor(majorMinor: MajorMinor) -> Color {
        switch majorMinor {
        case .minor:
            return minorColor
        case .neutral:
            return neutralColor
        case .major:
            return majorColor
        }
    }
    
    public func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        return majorMinorColor(majorMinor: majorMinor)
    }
    
    public func inactiveColor(isNatural: Bool) -> Color {
        return cellBackgroundColor
    }
    
    public func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        return cellBackgroundColor
    }
    
    public func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        return majorMinorColor(majorMinor: majorMinor)
    }
    
    public func activeOutlineColor(majorMinor: MajorMinor) -> Color {
        return cellBackgroundColor
    }
    
    public func inactiveOutlineColor(majorMinor: MajorMinor) -> Color {
        return majorMinorColor(majorMinor: majorMinor)
    }
    
    public var benignColor: Color {
        return neutralColor
    }
    
    public var cellBackgroundColor: Color {
        get {
            Color(cellBackgroundRGBAColor)
        }
        
        set {
            cellBackgroundRGBAColor = RGBAColor(newValue)
        }
    }
    
    public var majorColor: Color {
        get {
            Color(majorRGBAColor)
        }
        
        set {
            majorRGBAColor = RGBAColor(newValue)
        }
    }
    
    public var neutralColor: Color {
        get {
            Color(neutralRGBAColor)
        }
        
        set {
            neutralRGBAColor = RGBAColor(newValue)
        }
    }
    
    public var minorColor: Color {
        get {
            Color(minorRGBAColor)
        }
        
        set {
            minorRGBAColor = RGBAColor(newValue)
        }
    }
    
}
