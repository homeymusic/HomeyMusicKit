import Testing
import SwiftUI

@testable import HomeyMusicKit

final class IntervalClassTests {
    
    @Test func testIsTonic() async throws {
        let interval = IntervalClass.zero
        #expect(interval.isTonic == true)
    }
    
    @Test func testIsTritone() async throws {
        let interval = IntervalClass.six
        #expect(interval.isTritone == true)
    }
    
    @Test func testIsOctave() async throws {
        let interval = IntervalClass.twelve
        #expect(interval.isOctave == true)
    }
    
    @Test func testMajorMinor() async throws {
        #expect(IntervalClass.one.majorMinor == .minor)
        #expect(IntervalClass.two.majorMinor == .major)
        #expect(IntervalClass.zero.majorMinor == .neutral)
    }
    
    @Test func testConsonanceDissonance() async throws {
        #expect(IntervalClass.zero.consonanceDissonance == .tonic)
        #expect(IntervalClass.five.consonanceDissonance == .perfect)
        #expect(IntervalClass.eleven.consonanceDissonance == .dissonant)
    }
    
    @Test func testDegreeQuantityUpward() async throws {
        let interval = IntervalClass.four
        let pitchDirection = PitchDirection.upward
        #expect(interval.degreeQuantity(for: pitchDirection) == .three)
    }
    
    @Test func testDegreeQuantityDownward() async throws {
        let interval = IntervalClass.four
        let pitchDirection = PitchDirection.downward
        #expect(interval.degreeQuantity(for: pitchDirection) == .six)
    }
    
    @Test func testEmoji() async throws {
        let interval = IntervalClass.five
        let expectedImage = Image("tent_blue", bundle: .module)  // Matching based on image file name
        #expect(interval.emoji == expectedImage)
    }
    
    @Test func testMovableDo() async throws {
        let interval = IntervalClass.five
        #expect(interval.movableDo == "Fa")
    }
    
    // Pitch direction tests
    
    @Test func testDegreeWithPitchDirectionUpward() async throws {
        let interval = IntervalClass.three
        let pitchDirection = PitchDirection.upward
        #expect(interval.degree(for: pitchDirection) == "♭3̂")
    }
    
    @Test func testDegreeWithPitchDirectionDownward() async throws {
        let interval = IntervalClass.three
        let pitchDirection = PitchDirection.downward
        #expect(interval.degree(for: pitchDirection) == "<6̂")
    }
    
    @Test func testRomanWithPitchDirectionUpward() async throws {
        let interval = IntervalClass.five
        let pitchDirection = PitchDirection.upward
        #expect(interval.roman(for: pitchDirection) == "IV")
    }
    
    @Test func testRomanWithPitchDirectionDownward() async throws {
        let interval = IntervalClass.five
        let pitchDirection = PitchDirection.downward
        #expect(interval.roman(for: pitchDirection) == "<V")
    }
    
    @Test func testShorthandWithPitchDirectionUpward() async throws {
        let interval = IntervalClass.six
        let pitchDirection = PitchDirection.upward
        #expect(interval.shorthand(for: pitchDirection) == "tt")
    }
    
    @Test func testShorthandWithPitchDirectionDownward() async throws {
        let interval = IntervalClass.six
        let pitchDirection = PitchDirection.downward
        #expect(interval.shorthand(for: pitchDirection) == "<tt")
    }
    
    @Test func testLabelWithPitchDirectionUpward() async throws {
        let interval = IntervalClass.eight
        let pitchDirection = PitchDirection.upward
        #expect(interval.label(for: pitchDirection) == "upward minor sixth")
    }
    
    @Test func testLabelWithPitchDirectionDownward() async throws {
        let interval = IntervalClass.eight
        let pitchDirection = PitchDirection.downward
        #expect(interval.label(for: pitchDirection) == "downward minor third")
    }
    
    @Test func testAccidentalUpward() async throws {
        let interval = IntervalClass.two
        let pitchDirection = PitchDirection.upward
        #expect(interval.accidental(for: pitchDirection) == "")
    }
    
    @Test func testAccidentalDownward() async throws {
        let interval = IntervalClass.two
        let pitchDirection = PitchDirection.downward
        #expect(interval.accidental(for: pitchDirection) == "♯")
    }
}
