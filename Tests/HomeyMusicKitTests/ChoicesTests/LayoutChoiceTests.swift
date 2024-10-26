import MIDIKitCore
import Testing
@testable import HomeyMusicKit

@MainActor
final class LayoutChoiceTests {

    @Test
    func testLayoutChoiceIDs() {
        for choice in LayoutChoice.allCases {
            #expect(choice.id == choice.rawValue)
        }
    }

    @Test
    func testLayoutChoiceLabels() {
        #expect(LayoutChoice.tonic.label == "tonic picker")
        #expect(LayoutChoice.isomorphic.label == "isomorphic")
        #expect(LayoutChoice.symmetric.label == "symmetric")
        #expect(LayoutChoice.piano.label == "piano")
        #expect(LayoutChoice.strings.label == "strings")
    }

    @Test
    func testLayoutChoiceIcons() {
        #expect(LayoutChoice.tonic.icon == "house")
        #expect(LayoutChoice.isomorphic.icon == "rectangle.split.2x1")
        #expect(LayoutChoice.symmetric.icon == "rectangle.split.2x2")
        #expect(LayoutChoice.piano.icon == "pianokeys")
        #expect(LayoutChoice.strings.icon == "guitars")
    }

    @Test
    func testLayoutChoiceMidiChannel() {
        // Default MIDI channel tests
        #expect(LayoutChoice.tonic.midiChannel() == 15)
        #expect(LayoutChoice.isomorphic.midiChannel() == 0)
        #expect(LayoutChoice.symmetric.midiChannel() == 1)
        #expect(LayoutChoice.piano.midiChannel() == 2)

        // Test strings layout choice with default strings layout (violin)
        #expect(LayoutChoice.strings.midiChannel() == 3)

        // Test strings layout with other StringsLayoutChoice values
        #expect(LayoutChoice.strings.midiChannel(stringsLayoutChoice: .guitar) == 7)
        #expect(LayoutChoice.strings.midiChannel(stringsLayoutChoice: .bass) == 5)
        #expect(LayoutChoice.strings.midiChannel(stringsLayoutChoice: .banjo) == 6)
        #expect(LayoutChoice.strings.midiChannel(stringsLayoutChoice: .cello) == 4)
    }

    @Test
    func testLayoutChoiceMidiChannelLabel() {
        #expect(LayoutChoice.tonic.midiChannelLabel == "16")
        #expect(LayoutChoice.isomorphic.midiChannelLabel == "1")
        #expect(LayoutChoice.symmetric.midiChannelLabel == "2")
        #expect(LayoutChoice.piano.midiChannelLabel == "3")
        #expect(LayoutChoice.strings.midiChannelLabel == "4") // default to violin's midi channel (3 + 1)
    }
}
