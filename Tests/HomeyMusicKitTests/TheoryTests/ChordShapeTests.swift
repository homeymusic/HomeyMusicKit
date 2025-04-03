import Testing
@testable import HomeyMusicKit

final class ChordShapeTests {

    // Test ChordShape ID
    @Test func testChordShapeID() async throws {
        #expect(Chord.positive.id == "major")
        #expect(Chord.negative.id == "minor")
        #expect(Chord.positiveNegative.id == "mixed")
    }

    // Test ChordShape comparison
    @Test func testChordShapeComparison() async throws {
        let positive = Chord.positive
        let negative = Chord.negative
        #expect((positive < negative) == false)  // "major" is alphabetically after "minor"
        #expect((negative < positive) == true)
    }

    // Test ChordShape icon property
    @Test func testChordShapeIcon() async throws {
        let positive = Chord.positive
        let negative = Chord.negative
        let positiveInversion = Chord.positiveInversion
        #expect(positive.icon == "plus.square.fill")
        #expect(negative.icon == "minus.square.fill")
        #expect(positiveInversion.icon == "xmark.square.fill")
    }

    // Test ChordShape asciiSymbol property
    @Test func testChordShapeAsciiSymbol() async throws {
        let positive = Chord.positive
        let positiveNegative = Chord.positiveNegative
        #expect(positive.asciiSymbol == "+")
        #expect(positiveNegative.asciiSymbol == "+/-")
    }

    // Test ChordShape majorMinor property
    @Test func testChordShapeMajorMinor() async throws {
        let positive = Chord.positive
        let positiveInversion = Chord.positiveInversion
        let negative = Chord.negative
        let positiveNegative = Chord.positiveNegative
        #expect(positive.majorMinor == .major)
        #expect(positiveInversion.majorMinor == .major)
        #expect(negative.majorMinor == .minor)
        #expect(positiveNegative.majorMinor == .neutral)
    }
}
