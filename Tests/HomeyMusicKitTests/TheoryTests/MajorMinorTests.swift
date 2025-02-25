import Testing
import SwiftUI

@testable import HomeyMusicKit

// Test class for MajorMinor enum
final class MajorMinorTests {

    @Test func testMajorMinorComparison() async throws {
        #expect(MajorMinor.major > MajorMinor.neutral)
        #expect(MajorMinor.minor < MajorMinor.major)
        #expect(MajorMinor.neutral > MajorMinor.minor)
    }

    @Test func testLabel() async throws {
        #expect(MajorMinor.major.label == "major")
        #expect(MajorMinor.neutral.label == "neutral")
        #expect(MajorMinor.minor.label == "minor")
    }

    @Test func testComplement() async throws {
        #expect(MajorMinor.major.complement == .minor)
        #expect(MajorMinor.neutral.complement == .neutral)
        #expect(MajorMinor.minor.complement == .major)
    }

    @Test func testIcon() async throws {
        #expect(MajorMinor.major.icon == "paintbrush.pointed.fill")
        #expect(MajorMinor.neutral.icon == "paintbrush.pointed.fill")
        #expect(MajorMinor.minor.icon == "paintbrush.pointed.fill")
    }

    @Test func testIsCustomIcon() async throws {
        #expect(MajorMinor.major.isCustomIcon == false)
        #expect(MajorMinor.neutral.isCustomIcon == false)
        #expect(MajorMinor.minor.isCustomIcon == false)
    }

    @Test func testColor() async throws {
        #expect(MajorMinor.major.color == Color(.sRGB, red: 1, green: 0.6745098039, blue: 0.2, opacity: 1.0))
        #expect(MajorMinor.neutral.color == Color(.sRGB, red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, opacity: 1.0))
        #expect(MajorMinor.minor.color == Color(.sRGB, red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, opacity: 1.0))
    }

    @Test func testShortHand() async throws {
        #expect(MajorMinor.major.shortHand == "M")
        #expect(MajorMinor.neutral.shortHand == "P")
        #expect(MajorMinor.minor.shortHand == "m")
    }

    @Test func testAccidentalUpward() async throws {
        let pitchDirection = PitchDirection.upward
        #expect(MajorMinor.major.accidental(for: pitchDirection) == .none)
        #expect(MajorMinor.neutral.accidental(for: pitchDirection) == .none)
        #expect(MajorMinor.minor.accidental(for: pitchDirection) == .flat)
    }

    @Test func testAccidentalDownward() async throws {
        let pitchDirection = PitchDirection.downward
        #expect(MajorMinor.major.accidental(for: pitchDirection) == .sharp)
        #expect(MajorMinor.neutral.accidental(for: pitchDirection) == .none)
        #expect(MajorMinor.minor.accidental(for: pitchDirection) == .none)
    }

    @Test func testAltNeutralColor() async throws {
        #expect(MajorMinor.altNeutralColor == Color(.sRGB, red: 1.0, green: 0.333333, blue: 0.0, opacity: 1.0))
    }
    
    @Test func testId() async throws {
        #expect(MajorMinor.major.id == 1)
        #expect(MajorMinor.neutral.id == 0)
        #expect(MajorMinor.minor.id == -1)
    }
}
