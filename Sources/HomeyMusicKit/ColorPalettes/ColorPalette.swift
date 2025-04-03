import Foundation
import SwiftData

@Model
public class ColorPalette {
    
    // MARK: - Basic Info
    
    // SwiftData will auto-generate an 'id' for you if you like,
    // but here we'll be explicit:
    @Attribute(.unique) public var id: UUID
    
    public var name: String
    public var paletteType: PaletteType
    public var isSystemPalette: Bool

    public var symbol: String? // an SF Symbol name
       
    // MARK: - Core Colors (always needed)
    public var systemBackground: RGBAColor?
    public var systemForeground: RGBAColor?
    
    // MARK: - Fixed Type Colors
    public var natural: RGBAColor?
    public var accidental: RGBAColor?
    public var outline: RGBAColor?
    
    // MARK: - Movable Type Colors
    public var cellBackground: RGBAColor?
    public var major: RGBAColor?
    public var neutral: RGBAColor?
    public var minor: RGBAColor?
    
    // MARK: - Init
    
    public init(
        id: UUID = UUID(),
        name: String,
        paletteType: PaletteType,
        isSystemPalette: Bool = false,
        symbol: String? = nil,
        systemBackground: RGBAColor? = nil,
        systemForeground: RGBAColor? = nil,
        natural: RGBAColor? = nil,
        accidental: RGBAColor? = nil,
        outline: RGBAColor? = nil,
        cellBackground: RGBAColor? = nil,
        major: RGBAColor? = nil,
        neutral: RGBAColor? = nil,
        minor: RGBAColor? = nil
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.paletteType = paletteType
        self.isSystemPalette = isSystemPalette
        
        self.systemBackground = systemBackground
        self.systemForeground = systemForeground
        
        self.natural = natural
        self.accidental = accidental
        self.outline = outline
        
        self.cellBackground = cellBackground
        self.major = major
        self.neutral = neutral
        self.minor = minor
    }
}

public enum PaletteType: String, Codable {
    case fixed
    case movable
}
