import Testing
@testable import HomeyMusicKit

final class IntervalLabelChoiceTests {

    @Test func testAllCases() async throws {
        // Verify all cases are present
        let allCases: [IntervalLabelChoice] = [.symbol, .interval, .roman, .degree, .integer, .movableDo, .wavelengthRatio, .wavenumberRatio, .periodRatio, .frequencyRatio]
        #expect(IntervalLabelChoice.allCases == allCases)
    }
    
    @Test func testIcons() async throws {
        #expect(IntervalLabelChoice.symbol.icon == "nitterhouse.fill")
        #expect(IntervalLabelChoice.interval.icon == "p1.button.horizontal")
        #expect(IntervalLabelChoice.movableDo.icon == "person.wave.2")
        #expect(IntervalLabelChoice.roman.icon == "i.square")
        #expect(IntervalLabelChoice.degree.icon == "control")
        #expect(IntervalLabelChoice.integer.icon == "0.square")
        #expect(IntervalLabelChoice.wavelengthRatio.icon == "ruler")
        #expect(IntervalLabelChoice.wavenumberRatio.icon == "spatial.frequency")
        #expect(IntervalLabelChoice.periodRatio.icon == "stopwatch")
        #expect(IntervalLabelChoice.frequencyRatio.icon == "temporal.frequency")
    }
    
    @Test func testIsCustomIcon() async throws {
        #expect(IntervalLabelChoice.symbol.isCustomIcon == true)
        #expect(IntervalLabelChoice.interval.isCustomIcon == false)
        #expect(IntervalLabelChoice.roman.isCustomIcon == false)
        #expect(IntervalLabelChoice.movableDo.isCustomIcon == false)
        #expect(IntervalLabelChoice.degree.isCustomIcon == false)
        #expect(IntervalLabelChoice.integer.isCustomIcon == false)
        #expect(IntervalLabelChoice.wavelengthRatio.isCustomIcon == false)
        #expect(IntervalLabelChoice.wavenumberRatio.isCustomIcon == true)
        #expect(IntervalLabelChoice.periodRatio.isCustomIcon == false)
        #expect(IntervalLabelChoice.frequencyRatio.isCustomIcon == true)
    }

    @Test func testLabels() async throws {
        #expect(IntervalLabelChoice.symbol.label == "Symbol")
        #expect(IntervalLabelChoice.movableDo.label == "Movable Do")
        #expect(IntervalLabelChoice.interval.label == "Interval")
        #expect(IntervalLabelChoice.roman.label == "Roman Numeral")
        #expect(IntervalLabelChoice.degree.label == "Degree")
        #expect(IntervalLabelChoice.integer.label == "Integer Notation")
        #expect(IntervalLabelChoice.wavelengthRatio.label == "Wavelength Ratios")
        #expect(IntervalLabelChoice.wavenumberRatio.label == "Wavenumber Ratios")
        #expect(IntervalLabelChoice.periodRatio.label == "Period Ratios")
        #expect(IntervalLabelChoice.frequencyRatio.label == "Frequency Ratios")
    }

    @Test func testIds() async throws {
        // Test the `id` property for each case
        for choice in IntervalLabelChoice.allCases {
            #expect(choice.id == choice.rawValue)
        }
    }
}
