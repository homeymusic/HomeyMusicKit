import Testing
import SwiftUI
@testable import HomeyMusicKit

final class IntervalClassTests {
    
    // MARK: - Basic Properties
    
    @Test func testIdProperty() async throws {
        #expect(IntervalClass."P1".id == 0)
        #expect(IntervalClass.P8.id == 12)
    }
    
    @Test func testIsTonic() async throws {
        #expect(IntervalClass."P1".isTonic == true)
        #expect(IntervalClass.P4.isTonic == false)
    }
    
    @Test func testIsTritone() async throws {
        #expect(IntervalClass.tt.isTritone == true)
        #expect(IntervalClass.M4.isTritone == false)
    }
    
    @Test func testIsOctave() async throws {
        #expect(IntervalClass.P8.isOctave == true)
        #expect(IntervalClass.P5.isOctave == false)
    }

    // MARK: - Initialization and Comparison
    
    @Test func testCustomInitializer() async throws {
        #expect(IntervalClass(distance: 0) == ."P1")
        #expect(IntervalClass(distance: 25) == .m2)   // 25 mod 12 = 1
        #expect(IntervalClass(distance: 12) == .P8)
        #expect(IntervalClass(distance: -11) == .m2)  // -11 mod 12 = 1
    }
    
    @Test func testIntervalComparison() async throws {
        #expect((IntervalClass.M2 < IntervalClass.m7) == true)
        #expect((IntervalClass.P8 > IntervalClass.M7) == true)
    }
    
    // MARK: - Major Minor and Consonance/Dissonance
    
    @Test func testMajorMinorProperty() async throws {
        #expect(IntervalClass.m2.majorMinor == .minor)
        #expect(IntervalClass.m3.majorMinor == .minor)
        #expect(IntervalClass.m6.majorMinor == .minor)
        #expect(IntervalClass.m7.majorMinor == .minor)
        #expect(IntervalClass.M2.majorMinor == .major)
        #expect(IntervalClass.M4.majorMinor == .major)
        #expect(IntervalClass.M6.majorMinor == .major)
        #expect(IntervalClass.M7.majorMinor == .major)
        #expect(IntervalClass."P1".majorMinor == .neutral)
        #expect(IntervalClass.P4.majorMinor == .neutral)
        #expect(IntervalClass.tt.majorMinor == .neutral)
        #expect(IntervalClass.P5.majorMinor == .neutral)
    }
    
    @Test func testConsonanceDissonanceProperty() async throws {
        #expect(IntervalClass."P1".consonanceDissonance == .tonic)
        #expect(IntervalClass.m3.consonanceDissonance == .consonant)
        #expect(IntervalClass.P4.consonanceDissonance == .perfect)
        #expect(IntervalClass.M7.consonanceDissonance == .dissonant)
        #expect(IntervalClass.P8.consonanceDissonance == .octave)
    }

    // MARK: - Degree Quantity and Quality
    
    @Test func testDegreeQuality() async throws {
        let interval = IntervalClass.m3
        let upward = PitchDirection.upward
        let downward = PitchDirection.downward
        #expect(interval.degreeQuality(for: upward) == .minor)
        #expect(interval.degreeQuality(for: downward) == .major)  // Complement of minor
    }
    
    @Test func testDegreeQuantity() async throws {
        let interval = IntervalClass.M4
        #expect(interval.degreeQuantity(for: .upward) == .three)
        #expect(interval.degreeQuantity(for: .downward) == .six)
    }
    
    // MARK: - Emoji and Movable Do
    
    @Test func testEmojiFileName() async throws {
        #expect(IntervalClass.m2.emojiFileName == "stone_blue_hare")
        #expect(IntervalClass.M2.emojiFileName == "stone_gold")
        #expect(IntervalClass.m3.emojiFileName == "diamond_blue")
        #expect(IntervalClass.M4.emojiFileName == "diamond_gold_sun")
        #expect(IntervalClass.P4.emojiFileName == "tent_blue")
        #expect(IntervalClass.tt.emojiFileName == "disco")
        #expect(IntervalClass.P5.emojiFileName == "tent_gold")
        #expect(IntervalClass.m6.emojiFileName == "diamond_blue_rain")
        #expect(IntervalClass.M6.emojiFileName == "diamond_gold")
        #expect(IntervalClass.m7.emojiFileName == "stone_blue")
        #expect(IntervalClass.M7.emojiFileName == "stone_gold_hare")
        #expect(IntervalClass.P8.emojiFileName == "home")
    }
    
    @Test func testMovableDoProperty() async throws {
        #expect(IntervalClass."P1".movableDo == "Do")
        #expect(IntervalClass.m2.movableDo == "Di Ra")
        #expect(IntervalClass.M2.movableDo == "Re")
        #expect(IntervalClass.m3.movableDo == "Ri Me")
        #expect(IntervalClass.M4.movableDo == "Mi")
        #expect(IntervalClass.P4.movableDo == "Fa")
        #expect(IntervalClass.tt.movableDo == "Fi Se")
        #expect(IntervalClass.P5.movableDo == "Sol")
        #expect(IntervalClass.m6.movableDo == "Si Le")
        #expect(IntervalClass.M6.movableDo == "La")
        #expect(IntervalClass.m7.movableDo == "Li Te")
        #expect(IntervalClass.M7.movableDo == "Ti")
        #expect(IntervalClass.P8.movableDo == "Do")
    }
    
    // MARK: - Pitch Direction-Dependent Properties
    
    @Test func testDegreeWithPitchDirection() async throws {
        let interval = IntervalClass.m3
        let upward = PitchDirection.upward
        let downward = PitchDirection.downward
        #expect(interval.degree(for: upward) == "♭3̂")
        #expect(interval.degree(for: downward) == "<6̂")
    }
    
    @Test func testRomanWithPitchDirection() async throws {
        #expect(IntervalClass.P4.roman(for: .upward) == "IV")
        #expect(IntervalClass.P4.roman(for: .downward) == "<V")
    }
    
    @Test func testShorthandWithPitchDirection() async throws {
        #expect(IntervalClass.P4.shorthand(for: .upward) == "P4")
        #expect(IntervalClass.P4.shorthand(for: .downward) == "<P5")
        #expect(IntervalClass.tt.shorthand(for: .upward) == "tt")
        #expect(IntervalClass.tt.shorthand(for: .downward) == "<tt")
        #expect(IntervalClass.P5.shorthand(for: .upward) == "P5")
        #expect(IntervalClass.P5.shorthand(for: .downward) == "<P4")
    }
    
    @Test func testLabelWithPitchDirection() async throws {
        #expect(IntervalClass.tt.label(for: .upward) == "upward tritone")
        #expect(IntervalClass.tt.label(for: .downward) == "downward tritone")
        #expect(IntervalClass.m6.label(for: .upward) == "upward minor sixth")
        #expect(IntervalClass.m6.label(for: .downward) == "downward minor third")
    }
    
    // Tests for upward pitch direction
    @Test func testDegreeQuantityUpward() async throws {
        #expect(IntervalClass."P1".degreeQuantity(for: .upward) == .one)
        #expect(IntervalClass.m2.degreeQuantity(for: .upward) == .two)
        #expect(IntervalClass.M2.degreeQuantity(for: .upward) == .two)
        #expect(IntervalClass.m3.degreeQuantity(for: .upward) == .three)
        #expect(IntervalClass.M4.degreeQuantity(for: .upward) == .three)
        #expect(IntervalClass.P4.degreeQuantity(for: .upward) == .four)
        #expect(IntervalClass.tt.degreeQuantity(for: .upward) == .four)
        #expect(IntervalClass.P5.degreeQuantity(for: .upward) == .five)
        #expect(IntervalClass.m6.degreeQuantity(for: .upward) == .six)
        #expect(IntervalClass.M6.degreeQuantity(for: .upward) == .six)
        #expect(IntervalClass.m7.degreeQuantity(for: .upward) == .seven)
        #expect(IntervalClass.M7.degreeQuantity(for: .upward) == .seven)
        #expect(IntervalClass.P8.degreeQuantity(for: .upward) == .eight)
    }

    // Tests for downward pitch direction
    @Test func testDegreeQuantityDownward() async throws {
        #expect(IntervalClass."P1".degreeQuantity(for: .downward) == .one)
        #expect(IntervalClass.m7.degreeQuantity(for: .downward) == .two)
        #expect(IntervalClass.M7.degreeQuantity(for: .downward) == .two)
        #expect(IntervalClass.m2.degreeQuantity(for: .downward) == .seven)
        #expect(IntervalClass.M2.degreeQuantity(for: .downward) == .seven)
        #expect(IntervalClass.m3.degreeQuantity(for: .downward) == .six)
        #expect(IntervalClass.M4.degreeQuantity(for: .downward) == .six)
        #expect(IntervalClass.P4.degreeQuantity(for: .downward) == .five)
        #expect(IntervalClass.tt.degreeQuantity(for: .downward) == .four)
        #expect(IntervalClass.P5.degreeQuantity(for: .downward) == .four)
        #expect(IntervalClass.m6.degreeQuantity(for: .downward) == .three)
        #expect(IntervalClass.M6.degreeQuantity(for: .downward) == .three)
        #expect(IntervalClass.P8.degreeQuantity(for: .downward) == .eight)
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
