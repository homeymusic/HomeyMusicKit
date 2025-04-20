#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

// MARK: - Dynamic NSColor on macOS
#if os(macOS)
extension NSColor {
    /// Creates an NSColor that is `lightColor` in Light Mode and `darkColor` in Dark Mode.
    /// Fallbacks to `lightColor` on older OS versions without Dark Mode support.
    static func dynamic(light lightColor: NSColor, dark darkColor: NSColor) -> NSColor {
        guard #available(macOS 10.14, *) else {
            return lightColor
        }
        return NSColor(name: nil, dynamicProvider: { appearance in
            appearance.name == .darkAqua ? darkColor : lightColor
        })
    }
}
#endif

// MARK: - Cross-Platform System Grays
extension Color {
    public static var systemGray: Color {
        #if os(iOS)
        return Color(UIColor.systemGray)
        #else
        // Light: #8E8E93 (approx 0.56), Dark: #727278 (approx 0.45)
        let light = NSColor(srgbRed: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.45, green: 0.45, blue: 0.47, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
    
    public static var systemGray2: Color {
        #if os(iOS)
        return Color(UIColor.systemGray2)
        #else
        // Light: #AEAEB2 (approx 0.68), Dark: #636366 (approx 0.39)
        let light = NSColor(srgbRed: 0.68, green: 0.68, blue: 0.70, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.39, green: 0.39, blue: 0.40, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
    
    public static var systemGray3: Color {
        #if os(iOS)
        return Color(UIColor.systemGray3)
        #else
        // Light: #C7C7CC (approx 0.78), Dark: #48484A (approx 0.28)
        let light = NSColor(srgbRed: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.28, green: 0.28, blue: 0.29, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
    
    static var systemGray4: Color {
        #if os(iOS)
        return Color(UIColor.systemGray4)
        #else
        // Light: #D1D1D6 (approx 0.82), Dark: #3A3A3C (approx 0.23)
        let light = NSColor(srgbRed: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.23, green: 0.23, blue: 0.24, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
    
    public static var systemGray5: Color {
        #if os(iOS)
        return Color(UIColor.systemGray5)
        #else
        // Light: #E5E5EA (approx 0.90), Dark: #2C2C2E (approx 0.17)
        let light = NSColor(srgbRed: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
    
    public static var systemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        // Light: #F2F2F7 (approx 0.95), Dark: #1C1C1E (approx 0.11)
        let light = NSColor(srgbRed: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        let dark  = NSColor(srgbRed: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        return Color(NSColor.dynamic(light: light, dark: dark))
        #endif
    }
}

// MARK: - Hue/Saturation/Brightness Adjustment
@available(macOS 10.15, iOS 13.0, *)
extension Color {
    public func adjust(hue: CGFloat = 0,
                       saturation: CGFloat = 0,
                       brightness: CGFloat = 0,
                       opacity: CGFloat = 1) -> Color
    {
        #if canImport(UIKit)
        if #available(iOS 17.0, *) {
            let uiColor = UIColor(self)
            var currentHue: CGFloat = 0
            var currentSaturation: CGFloat = 0
            var currentBrightness: CGFloat = 0
            var currentOpacity: CGFloat = 0
            
            if uiColor.getHue(&currentHue,
                              saturation: &currentSaturation,
                              brightness: &currentBrightness,
                              alpha: &currentOpacity)
            {
                return Color(hue: currentHue + hue,
                             saturation: currentSaturation + saturation,
                             brightness: currentBrightness + brightness,
                             opacity: currentOpacity + opacity)
            }
        }
        #elseif canImport(AppKit)
        if #available(macOS 11.0, *) {
            let nsColor = NSColor(self)
            var currentHue: CGFloat = 0
            var currentSaturation: CGFloat = 0
            var currentBrightness: CGFloat = 0
            var currentOpacity: CGFloat = 0
            
            if nsColor.usingColorSpace(.deviceRGB)?
                      .getHue(&currentHue,
                              saturation: &currentSaturation,
                              brightness: &currentBrightness,
                              alpha: &currentOpacity) != nil
            {
                return Color(hue: currentHue + hue,
                             saturation: currentSaturation + saturation,
                             brightness: currentBrightness + brightness,
                             opacity: currentOpacity + opacity)
            }
        }
        #endif
        return self
    }
}

// MARK: - RGBAColor + Conversions
public struct RGBAColor: Sendable, Codable, Hashable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension RGBAColor {
    public init(_ color: Color) {
        #if os(iOS) || os(tvOS) || os(watchOS)
        let platformColor = UIColor(color)
        #else
        let platformColor = NSColor(color)
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        #if os(macOS)
        if let rgbColor = platformColor.usingColorSpace(.extendedSRGB) {
            rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            // Fallback if the color cannot be converted
            r = 0
            g = 0
            b = 0
            a = 0
        }
        #else
        platformColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        
        self.init(red: Double(r),
                  green: Double(g),
                  blue: Double(b),
                  alpha: Double(a))
    }
}

public extension Color {
    public init(_ rgba: RGBAColor) {
        self.init(
            red: rgba.red,
            green: rgba.green,
            blue: rgba.blue,
            opacity: rgba.alpha
        )
    }
}
