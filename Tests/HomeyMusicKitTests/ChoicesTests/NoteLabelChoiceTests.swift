import Testing
@testable import HomeyMusicKit

final class NoteLabelChoiceTests {

    @Test func testNoteLabelChoiceIcons() {
        let iconExpectations: [NoteLabelChoice: String] = [
            .letter: "c.square",
            .fixedDo: "person.2.wave.2",
            .accidentals: "number.square",
            .octave: "4.square",
            .midi: "60.square",
            .wavelength: "ruler",
            .wavenumber: "spatial.frequency",
            .period: "stopwatch",
            .frequency: "temporal.frequency",
            .cochlea: "fossil.shell",
            .mode: "building.columns",
            .map: "location.fill.viewfinder",
            .month: "calendar"
        ]
        
        for (choice, expectedIcon) in iconExpectations {
            #expect(choice.icon == expectedIcon)
        }
    }

    @Test func testNoteLabelChoiceIsCustomIcon() {
        #expect(NoteLabelChoice.midi.isCustomIcon == true)
        #expect(NoteLabelChoice.wavenumber.isCustomIcon == true)
        #expect(NoteLabelChoice.frequency.isCustomIcon == true)
        #expect(NoteLabelChoice.octave.isCustomIcon == false)
        #expect(NoteLabelChoice.cochlea.isCustomIcon == false)
    }

    @Test func testNoteLabelChoiceLabels() {
        let labelExpectations: [NoteLabelChoice: String] = [
            .letter: "Letter",
            .fixedDo: "Fixed Do",
            .accidentals: "Accidentals",
            .octave: "Octave",
            .midi: "MIDI",
            .wavelength: "Wavelength",
            .wavenumber: "Wavenumber",
            .period: "Period",
            .frequency: "Frequency",
            .cochlea: "Cochlea",
            .mode: "Mode",
            .map: "Guide",
            .month: "Month"
        ]
        
        for (choice, expectedLabel) in labelExpectations {
            #expect(choice.label == expectedLabel)
        }
    }

    @Test func testPitchClassCases() {
        let pitchClassCases = NoteLabelChoice.pitchClassCases
        let expectedCases: [NoteLabelChoice] = [.letter, .accidentals, .fixedDo, .month]
        #expect(pitchClassCases == expectedCases)
    }
    
    @Test func testIds() async throws {
        // Test the `id` property for each case
        for choice in NoteLabelChoice.allCases {
            #expect(choice.id == choice.rawValue)
        }
    }

}
