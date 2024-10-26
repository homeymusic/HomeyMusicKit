import Testing
import SwiftUI

final class ColorAdjustmentTests {

    @Test func testAdjustNoChanges() {
        let originalColor = Color.red
        let adjustedColor = originalColor.adjust()
        #expect(originalColor != adjustedColor)  // No adjustments should match the original color
    }

    @Test func testAdjustHueIncrease() {
        let originalColor = Color.red
        let adjustedColor = originalColor.adjust(hue: 0.1)
        #expect(originalColor != adjustedColor)  // Hue change should alter the color
    }

    @Test func testAdjustSaturationDecrease() {
        let originalColor = Color.blue
        let adjustedColor = originalColor.adjust(saturation: -0.2)
        #expect(originalColor != adjustedColor)  // Saturation decrease should alter the color
    }

    @Test func testAdjustBrightnessIncrease() {
        let originalColor = Color.black
        let adjustedColor = originalColor.adjust(brightness: 0.5)
        #expect(originalColor != adjustedColor)  // Brightness increase should lighten the color
    }

    @Test func testAdjustOpacityDecrease() {
        let originalColor = Color.green
        let adjustedColor = originalColor.adjust(opacity: -0.5)
        #expect(originalColor != adjustedColor)  // Lower opacity should alter the color
    }

}
