import Testing
@testable import HomeyMusicKit

final class PitchDirectionTests {
    
    @Test func testDefaultPitchDirection() async throws {
        #expect(PitchDirection.default == .upward)
    }

    @Test func testIcon() async throws {
        #expect(PitchDirection.upward.icon == "greaterthan.square")
        #expect(PitchDirection.downward.icon == "lessthan.square")
        #expect(PitchDirection.both.icon == "equal.square")
    }

    @Test func testIsCustomIcon() async throws {
        #expect(PitchDirection.upward.isCustomIcon == false)
        #expect(PitchDirection.both.isCustomIcon == false)
        #expect(PitchDirection.downward.isCustomIcon == false)
    }

    @Test func testIsUpward() async throws {
        #expect(PitchDirection.upward.isUpward == true)
        #expect(PitchDirection.downward.isUpward == false)
        #expect(PitchDirection.both.isUpward == true)  // Default behavior, both considered upward
    }

    @Test func testAsciiSymbol() async throws {
        #expect(PitchDirection.upward.asciiSymbol == ">")
        #expect(PitchDirection.both.asciiSymbol == "=")
        #expect(PitchDirection.downward.asciiSymbol == "<")
    }

    @Test func testMajorMinor() async throws {
        #expect(PitchDirection.upward.majorMinor == .major)
        #expect(PitchDirection.both.majorMinor == .neutral)
        #expect(PitchDirection.downward.majorMinor == .minor)
    }

    @Test func testShortHand() async throws {
        #expect(PitchDirection.upward.shortHand == "")
        #expect(PitchDirection.downward.shortHand == "<")
        #expect(PitchDirection.both.shortHand == "")
    }

    @Test func testLabel() async throws {
        #expect(PitchDirection.upward.label == "upward")
        #expect(PitchDirection.downward.label == "downward")
        #expect(PitchDirection.both.label == "upward or downward")
    }
}
