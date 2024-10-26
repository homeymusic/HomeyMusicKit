import Testing
import SwiftUI
@testable import HomeyMusicKit

final class IntervalClassTests {
    
    // MARK: - Basic Properties
    
    @Test func testIdProperty() async throws {
        #expect(IntervalClass.zero.id == 0)
        #expect(IntervalClass.twelve.id == 12)
    }
    
    @Test func testIsTonic() async throws {
        #expect(IntervalClass.zero.isTonic == true)
        #expect(IntervalClass.five.isTonic == false)
    }
    
    @Test func testIsTritone() async throws {
        #expect(IntervalClass.six.isTritone == true)
        #expect(IntervalClass.four.isTritone == false)
    }
    
    @Test func testIsOctave() async throws {
        #expect(IntervalClass.twelve.isOctave == true)
        #expect(IntervalClass.seven.isOctave == false)
    }

    // MARK: - Initialization and Comparison
    
    @Test func testCustomInitializer() async throws {
        #expect(IntervalClass(distance: 0) == .zero)
        #expect(IntervalClass(distance: 25) == .one)   // 25 mod 12 = 1
        #expect(IntervalClass(distance: 12) == .twelve)
        #expect(IntervalClass(distance: -11) == .one)  // -11 mod 12 = 1
    }
    
    @Test func testIntervalComparison() async throws {
        #expect((IntervalClass.two < IntervalClass.ten) == true)
        #expect((IntervalClass.twelve > IntervalClass.eleven) == true)
    }
    
    // MARK: - Major Minor and Consonance/Dissonance
    
    @Test func testMajorMinorProperty() async throws {
        #expect(IntervalClass.one.majorMinor == .minor)
        #expect(IntervalClass.two.majorMinor == .major)
        #expect(IntervalClass.zero.majorMinor == .neutral)
    }
    
    @Test func testConsonanceDissonanceProperty() async throws {
        #expect(IntervalClass.zero.consonanceDissonance == .tonic)
        #expect(IntervalClass.three.consonanceDissonance == .consonant)
        #expect(IntervalClass.five.consonanceDissonance == .perfect)
        #expect(IntervalClass.eleven.consonanceDissonance == .dissonant)
        #expect(IntervalClass.twelve.consonanceDissonance == .octave)
    }

    // MARK: - Degree Quantity and Quality
    
    @Test func testDegreeQuality() async throws {
        let interval = IntervalClass.three
        let upward = PitchDirection.upward
        let downward = PitchDirection.downward
        #expect(interval.degreeQuality(for: upward) == .minor)
        #expect(interval.degreeQuality(for: downward) == .major)  // Complement of minor
    }
    
    @Test func testDegreeQuantity() async throws {
        let interval = IntervalClass.four
        #expect(interval.degreeQuantity(for: .upward) == .three)
        #expect(interval.degreeQuantity(for: .downward) == .six)
    }
    
    // MARK: - Emoji and Movable Do
    
    @Test func testEmojiFileName() async throws {
        #expect(IntervalClass.one.emojiFileName == "stone_blue_hare")
        #expect(IntervalClass.two.emojiFileName == "stone_gold")
        #expect(IntervalClass.three.emojiFileName == "diamond_blue")
        #expect(IntervalClass.four.emojiFileName == "diamond_gold_sun")
        #expect(IntervalClass.five.emojiFileName == "tent_blue")
        #expect(IntervalClass.six.emojiFileName == "disco")
        #expect(IntervalClass.seven.emojiFileName == "tent_gold")
        #expect(IntervalClass.eight.emojiFileName == "diamond_blue_rain")
        #expect(IntervalClass.nine.emojiFileName == "diamond_gold")
        #expect(IntervalClass.ten.emojiFileName == "stone_blue")
        #expect(IntervalClass.eleven.emojiFileName == "stone_gold_hare")
        #expect(IntervalClass.twelve.emojiFileName == "home")
    }
    
    @Test func testMovableDoProperty() async throws {
        #expect(IntervalClass.zero.movableDo == "Do")
        #expect(IntervalClass.one.movableDo == "Di Ra")
        #expect(IntervalClass.two.movableDo == "Re")
        #expect(IntervalClass.three.movableDo == "Ri Me")
        #expect(IntervalClass.four.movableDo == "Mi")
        #expect(IntervalClass.five.movableDo == "Fa")
        #expect(IntervalClass.six.movableDo == "Fi Se")
        #expect(IntervalClass.seven.movableDo == "Sol")
        #expect(IntervalClass.eight.movableDo == "Si Le")
        #expect(IntervalClass.nine.movableDo == "La")
        #expect(IntervalClass.ten.movableDo == "Li Te")
        #expect(IntervalClass.eleven.movableDo == "Ti")
        #expect(IntervalClass.twelve.movableDo == "Do")
    }
    
    // MARK: - Pitch Direction-Dependent Properties
    
    @Test func testDegreeWithPitchDirection() async throws {
        let interval = IntervalClass.three
        let upward = PitchDirection.upward
        let downward = PitchDirection.downward
        #expect(interval.degree(for: upward) == "♭3̂")
        #expect(interval.degree(for: downward) == "<6̂")
    }
    
    @Test func testRomanWithPitchDirection() async throws {
        #expect(IntervalClass.five.roman(for: .upward) == "IV")
        #expect(IntervalClass.five.roman(for: .downward) == "<V")
    }
    
    @Test func testShorthandWithPitchDirection() async throws {
        #expect(IntervalClass.five.shorthand(for: .upward) == "P4")
        #expect(IntervalClass.five.shorthand(for: .downward) == "<P5")
        #expect(IntervalClass.six.shorthand(for: .upward) == "tt")
        #expect(IntervalClass.six.shorthand(for: .downward) == "<tt")
        #expect(IntervalClass.seven.shorthand(for: .upward) == "P5")
        #expect(IntervalClass.seven.shorthand(for: .downward) == "<P4")
    }
    
    @Test func testLabelWithPitchDirection() async throws {
        #expect(IntervalClass.six.label(for: .upward) == "upward tritone")
        #expect(IntervalClass.six.label(for: .downward) == "downward tritone")
        #expect(IntervalClass.eight.label(for: .upward) == "upward minor sixth")
        #expect(IntervalClass.eight.label(for: .downward) == "downward minor third")
    }
    
    // Tests for upward pitch direction
    @Test func testDegreeQuantityUpward() async throws {
        #expect(IntervalClass.zero.degreeQuantity(for: .upward) == .one)
        #expect(IntervalClass.one.degreeQuantity(for: .upward) == .two)
        #expect(IntervalClass.two.degreeQuantity(for: .upward) == .two)
        #expect(IntervalClass.three.degreeQuantity(for: .upward) == .three)
        #expect(IntervalClass.four.degreeQuantity(for: .upward) == .three)
        #expect(IntervalClass.five.degreeQuantity(for: .upward) == .four)
        #expect(IntervalClass.six.degreeQuantity(for: .upward) == .four)
        #expect(IntervalClass.seven.degreeQuantity(for: .upward) == .five)
        #expect(IntervalClass.eight.degreeQuantity(for: .upward) == .six)
        #expect(IntervalClass.nine.degreeQuantity(for: .upward) == .six)
        #expect(IntervalClass.ten.degreeQuantity(for: .upward) == .seven)
        #expect(IntervalClass.eleven.degreeQuantity(for: .upward) == .seven)
        #expect(IntervalClass.twelve.degreeQuantity(for: .upward) == .eight)
    }

    // Tests for downward pitch direction
    @Test func testDegreeQuantityDownward() async throws {
        #expect(IntervalClass.zero.degreeQuantity(for: .downward) == .one)
        #expect(IntervalClass.ten.degreeQuantity(for: .downward) == .two)
        #expect(IntervalClass.eleven.degreeQuantity(for: .downward) == .two)
        #expect(IntervalClass.one.degreeQuantity(for: .downward) == .seven)
        #expect(IntervalClass.two.degreeQuantity(for: .downward) == .seven)
        #expect(IntervalClass.three.degreeQuantity(for: .downward) == .six)
        #expect(IntervalClass.four.degreeQuantity(for: .downward) == .six)
        #expect(IntervalClass.five.degreeQuantity(for: .downward) == .five)
        #expect(IntervalClass.six.degreeQuantity(for: .downward) == .four)
        #expect(IntervalClass.seven.degreeQuantity(for: .downward) == .four)
        #expect(IntervalClass.eight.degreeQuantity(for: .downward) == .three)
        #expect(IntervalClass.nine.degreeQuantity(for: .downward) == .three)
        #expect(IntervalClass.twelve.degreeQuantity(for: .downward) == .eight)
    }

    @Test func testMajorMinorDistance() async throws {
        #expect(IntervalClass.majorMinor(0) == .neutral)      // P1
        #expect(IntervalClass.majorMinor(4) == .major)        // M3
        #expect(IntervalClass.majorMinor(7) == .neutral)      // P5
        #expect(IntervalClass.majorMinor(10) == .minor)       // m7
        #expect(IntervalClass.majorMinor(12) == .neutral)     // P8
        #expect(IntervalClass.majorMinor(-3) == .major)       // Wrap-around with modulo, testing negative
    }
}
