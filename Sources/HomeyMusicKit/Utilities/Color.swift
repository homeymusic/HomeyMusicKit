import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
extension Color {
    public func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        #if canImport(UIKit)
        if #available(iOS 17.0, *) {
            let color = UIColor(self)
            var currentHue: CGFloat = 0
            var currentSaturation: CGFloat = 0
            var currentBrightness: CGFloat = 0
            var currentOpacity: CGFloat = 0

            if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: &currentOpacity) {
                return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrightness + brightness, opacity: currentOpacity + opacity)
            }
        }
        #elseif canImport(AppKit)
        if #available(macOS 11.0, *) {
            let color = NSColor(self)
            var currentHue: CGFloat = 0
            var currentSaturation: CGFloat = 0
            var currentBrightness: CGFloat = 0
            var currentOpacity: CGFloat = 0

            if color.usingColorSpace(.deviceRGB)?.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: &currentOpacity) != nil {
                return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrightness + brightness, opacity: currentOpacity + opacity)
            }
        }
        #endif
        return self
    }
}
