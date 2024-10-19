import Testing
import SwiftUI

@testable import HomeyMusicKit

final class AccidentalTests {

    // Test default accidental
    @Test func testDefaultAccidental() async throws {
        #expect(Accidental.default == .sharp)
    }

    // Test id property
    @Test func testAccidentalID() async throws {
        let accidental = Accidental.flat
        #expect(accidental.id == -1)
    }

    // Test icon (which returns asciiSymbol)
    @Test func testAccidentalIcon() async throws {
        let flatAccidental = Accidental.flat
        let sharpAccidental = Accidental.sharp
        let noneAccidental = Accidental.none

        #expect(flatAccidental.icon == "♭")
        #expect(sharpAccidental.icon == "♯")
        #expect(noneAccidental.icon == "")
    }

    // Test majorMinor property
    @Test func testMajorMinor() async throws {
        let flatAccidental = Accidental.flat
        let sharpAccidental = Accidental.sharp
        let noneAccidental = Accidental.none

        #expect(flatAccidental.majorMinor == .minor)
        #expect(sharpAccidental.majorMinor == .major)
        #expect(noneAccidental.majorMinor == .neutral)
    }

    // Test shorthand property (which returns asciiSymbol)
    @Test func testShortHand() async throws {
        let sharpAccidental = Accidental.sharp
        let noneAccidental = Accidental.none

        #expect(sharpAccidental.shortHand == "♯")
        #expect(noneAccidental.shortHand == "")
    }

    // Test label property (which returns asciiSymbol)
    @Test func testLabel() async throws {
        let flatAccidental = Accidental.flat
        let sharpAccidental = Accidental.sharp

        #expect(flatAccidental.label == "♭")
        #expect(sharpAccidental.label == "♯")
    }
}
