import Testing
@testable import HomeyMusicKit

final class PaletteChoiceTests {

    @Test func testIcon() async throws {
        #expect(PaletteChoice.subtle.icon == "paintpalette")
        #expect(PaletteChoice.loud.icon == "paintpalette.fill")
        #expect(PaletteChoice.ebonyIvory.icon == "circle.lefthalf.filled")
    }
    
    @Test func testLabel() async throws {
        #expect(PaletteChoice.subtle.label == "Subtle")
        #expect(PaletteChoice.loud.label == "Loud")
        #expect(PaletteChoice.ebonyIvory.label == "Piano")
    }
    
    @Test func testId() async throws {
        #expect(PaletteChoice.subtle.id == "subtle")
        #expect(PaletteChoice.loud.id == "loud")
        #expect(PaletteChoice.ebonyIvory.id == "piano")
    }
}
