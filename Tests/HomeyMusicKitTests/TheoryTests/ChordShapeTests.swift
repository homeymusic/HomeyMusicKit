import Testing
@testable import HomeyMusicKit

final class ChordShapeTests {

    // Test ChordShape ID
    @Test func testChordShapeID() async throws {
        #expect(ChordShape.positive.id == "major")
        #expect(ChordShape.negative.id == "minor")
        #expect(ChordShape.positiveNegative.id == "mixed")
    }

    // Test ChordShape comparison
    @Test func testChordShapeComparison() async throws {
        let positive = ChordShape.positive
        let negative = ChordShape.negative
        #expect((positive < negative) == false)  // "major" is alphabetically after "minor"
        #expect((negative < positive) == true)
    }

    // Test ChordShape icon property
    @Test func testChordShapeIcon() async throws {
        let positive = ChordShape.positive
        let negative = ChordShape.negative
        let positiveInversion = ChordShape.positiveInversion
        #expect(positive.icon == "plus.square.fill")
        #expect(negative.icon == "minus.square.fill")
        #expect(positiveInversion.icon == "xmark.square.fill")
    }

    // Test ChordShape asciiSymbol property
    @Test func testChordShapeAsciiSymbol() async throws {
        let positive = ChordShape.positive
        let positiveNegative = ChordShape.positiveNegative
        #expect(positive.asciiSymbol == "+")
        #expect(positiveNegative.asciiSymbol == "+/-")
    }

    // Test ChordShape majorMinor property
    @Test func testChordShapeMajorMinor() async throws {
        let positive = ChordShape.positive
        let positiveInversion = ChordShape.positiveInversion
        let negative = ChordShape.negative
        let positiveNegative = ChordShape.positiveNegative
        #expect(positive.majorMinor == .major)
        #expect(positiveInversion.majorMinor == .major)
        #expect(negative.majorMinor == .minor)
        #expect(positiveNegative.majorMinor == .neutral)
    }
}
