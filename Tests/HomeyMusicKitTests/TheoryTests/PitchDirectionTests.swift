import Testing
@testable import HomeyMusicKit

final class PitchDirectionTests {
    
    @Test func testDefaultPitchDirection() async throws {
        #expect(PitchDirection.default == .upward)
    }

    @Test func testIcon() async throws {
        #expect(PitchDirection.upward.icon == "greaterthan.square")
        #expect(PitchDirection.downward.icon == "lessthan.square")
        #expect(PitchDirection.mixed.icon == "equal.square")
    }

    @Test func testIsCustomIcon() async throws {
        #expect(PitchDirection.upward.isCustomIcon == false)
        #expect(PitchDirection.mixed.isCustomIcon == false)
        #expect(PitchDirection.downward.isCustomIcon == false)
    }

    @Test func testIsUpward() async throws {
        #expect(PitchDirection.upward.isUpward == true)
        #expect(PitchDirection.downward.isUpward == false)
        #expect(PitchDirection.mixed.isUpward == true)  // Default behavior, both considered upward
    }

    @Test func testAsciiSymbol() async throws {
        #expect(PitchDirection.upward.asciiSymbol == ">")
        #expect(PitchDirection.mixed.asciiSymbol == "=")
        #expect(PitchDirection.downward.asciiSymbol == "<")
    }

    @Test func testMajorMinor() async throws {
        #expect(PitchDirection.upward.majorMinor == .major)
        #expect(PitchDirection.mixed.majorMinor == .neutral)
        #expect(PitchDirection.downward.majorMinor == .minor)
    }

    @Test func testShortHand() async throws {
        #expect(PitchDirection.upward.shortHand == "")
        #expect(PitchDirection.downward.shortHand == "<")
        #expect(PitchDirection.mixed.shortHand == "")
    }

    @Test func testLabel() async throws {
        #expect(PitchDirection.upward.label   == "upward")
        #expect(PitchDirection.downward.label == "downward")
        #expect(PitchDirection.mixed.label    == "mixed")
    }
    
    @Test func testId() async throws {
        #expect(PitchDirection.upward.id == 2)
        #expect(PitchDirection.downward.id == 0)
        #expect(PitchDirection.mixed.id == 1)
    }
}
