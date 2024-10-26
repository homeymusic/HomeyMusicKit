import Testing
@testable import HomeyMusicKit

final class StringsLayoutChoiceTests {

    @Test func testIdAndLabel() async throws {
        for choice in StringsLayoutChoice.allCases {
            #expect(choice.id == choice.rawValue)
            #expect(choice.label == choice.rawValue)
        }
    }
    
    @Test func testOpenStringsMIDI() async throws {
        #expect(StringsLayoutChoice.guitar.openStringsMIDI == [64, 59, 55, 50, 45, 40])
        #expect(StringsLayoutChoice.bass.openStringsMIDI == [55, 50, 45, 40])
        #expect(StringsLayoutChoice.violin.openStringsMIDI == [76, 69, 62, 55])
        #expect(StringsLayoutChoice.cello.openStringsMIDI == [69, 62, 55, 48])
        #expect(StringsLayoutChoice.banjo.openStringsMIDI == [62, 59, 55, 50, 62])
    }
    
    @Test func testMidiChannel() async throws {
        #expect(StringsLayoutChoice.violin.midiChannel == 3)
        #expect(StringsLayoutChoice.cello.midiChannel == 4)
        #expect(StringsLayoutChoice.bass.midiChannel == 5)
        #expect(StringsLayoutChoice.banjo.midiChannel == 6)
        #expect(StringsLayoutChoice.guitar.midiChannel == 7)
    }
    
    @Test func testMidiChannelLabel() async throws {
        #expect(StringsLayoutChoice.violin.midiChannelLabel == "4")
        #expect(StringsLayoutChoice.cello.midiChannelLabel == "5")
        #expect(StringsLayoutChoice.bass.midiChannelLabel == "6")
        #expect(StringsLayoutChoice.banjo.midiChannelLabel == "7")
        #expect(StringsLayoutChoice.guitar.midiChannelLabel == "8")
    }
}
