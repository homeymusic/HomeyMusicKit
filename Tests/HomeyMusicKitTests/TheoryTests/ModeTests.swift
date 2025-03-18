import Testing
@testable import HomeyMusicKit

final class ModeTests {
    
    @Test func testLabel() async throws {
        #expect(Mode.ionian.label == "ionian")
        #expect(Mode.mixolydianPentatonic.label == "mixolydian pentatonic")
        #expect(Mode.dorian.label == "dorian")
        #expect(Mode.aeolianPentatonic.label == "aeolian pentatonic")
        #expect(Mode.phrygian.label == "phrygian")
        #expect(Mode.lydian.label == "lydian")
        #expect(Mode.ionianPentatonic.label == "ionian pentatonic")
        #expect(Mode.mixolydian.label == "mixolydian")
        #expect(Mode.dorianPentatonic.label == "dorian pentatonic")
        #expect(Mode.aeolian.label == "aeolian")
        #expect(Mode.phrygianPentatonic.label == "phrygian pentatonic")
        #expect(Mode.locrian.label == "locrian")
    }
    
    @Test func testShortHand() async throws {
        #expect(Mode.ionian.shortHand == "ION")
        #expect(Mode.mixolydianPentatonic.shortHand == "mix")
        #expect(Mode.dorian.shortHand == "DOR")
        #expect(Mode.aeolianPentatonic.shortHand == "aeo")
        #expect(Mode.phrygian.shortHand == "PHR")
        #expect(Mode.lydian.shortHand == "LYD")
        #expect(Mode.ionianPentatonic.shortHand == "ion")
        #expect(Mode.mixolydian.shortHand == "MIX")
        #expect(Mode.dorianPentatonic.shortHand == "dor")
        #expect(Mode.aeolian.shortHand == "AEO")
        #expect(Mode.phrygianPentatonic.shortHand == "phr")
        #expect(Mode.locrian.shortHand == "LOC")
    }
    
    @Test func testPitchDirection() async throws {
        #expect(Mode.ionian.pitchDirection == .upward)
        #expect(Mode.mixolydianPentatonic.pitchDirection == .downward)
        #expect(Mode.dorian.pitchDirection == .mixed)
        #expect(Mode.aeolianPentatonic.pitchDirection == .upward)
        #expect(Mode.phrygian.pitchDirection == .downward)
        #expect(Mode.lydian.pitchDirection == .upward)
        #expect(Mode.ionianPentatonic.pitchDirection == .upward)
        #expect(Mode.mixolydian.pitchDirection == .downward)
        #expect(Mode.dorianPentatonic.pitchDirection == .mixed)
        #expect(Mode.aeolian.pitchDirection == .upward)
        #expect(Mode.phrygianPentatonic.pitchDirection == .downward)
        #expect(Mode.locrian.pitchDirection == .downward)
    }
    
    @Test func testChordShape() async throws {
        #expect(Mode.ionian.chordShape == .positive)
        #expect(Mode.mixolydianPentatonic.chordShape == .positive)
        #expect(Mode.dorian.chordShape == .positiveNegative)
        #expect(Mode.aeolianPentatonic.chordShape == .negative)
        #expect(Mode.phrygian.chordShape == .negative)
        #expect(Mode.lydian.chordShape == .positiveInversion)
        #expect(Mode.ionianPentatonic.chordShape == .positive)
        #expect(Mode.mixolydian.chordShape == .positive)
        #expect(Mode.dorianPentatonic.chordShape == .positiveNegative)
        #expect(Mode.aeolian.chordShape == .negative)
        #expect(Mode.phrygianPentatonic.chordShape == .negative)
        #expect(Mode.locrian.chordShape == .negativeInversion)
    }

    @Test func testMajorMinor() async throws {
        #expect(Mode.ionian.majorMinor == .major)
        #expect(Mode.mixolydianPentatonic.majorMinor == .major)
        #expect(Mode.dorian.majorMinor == .neutral)
        #expect(Mode.aeolianPentatonic.majorMinor == .minor)
        #expect(Mode.phrygian.majorMinor == .minor)
        #expect(Mode.lydian.majorMinor == .major)
        #expect(Mode.ionianPentatonic.majorMinor == .major)
        #expect(Mode.mixolydian.majorMinor == .major)
        #expect(Mode.dorianPentatonic.majorMinor == .neutral)
        #expect(Mode.aeolian.majorMinor == .minor)
        #expect(Mode.phrygianPentatonic.majorMinor == .minor)
        #expect(Mode.locrian.majorMinor == .minor)
    }
    
    @Test func testScale() async throws {
        #expect(Mode.ionian.scale == .heptatonic)
        #expect(Mode.mixolydianPentatonic.scale == .pentatonic)
        #expect(Mode.dorian.scale == .heptatonic)
        #expect(Mode.aeolianPentatonic.scale == .pentatonic)
        #expect(Mode.phrygian.scale == .heptatonic)
        #expect(Mode.lydian.scale == .heptatonic)
        #expect(Mode.ionianPentatonic.scale == .pentatonic)
        #expect(Mode.mixolydian.scale == .heptatonic)
        #expect(Mode.dorianPentatonic.scale == .pentatonic)
        #expect(Mode.aeolian.scale == .heptatonic)
        #expect(Mode.phrygianPentatonic.scale == .pentatonic)
        #expect(Mode.locrian.scale == .heptatonic)
    }
    
    @Test func testComparison() async throws {
        #expect((Mode.ionian > Mode.phrygian) == true)
        #expect((Mode.mixolydian > Mode.aeolian) == true)
    }
    
    @Test func testId() async throws {
        #expect(Mode.ionian.id == "0")
        #expect(Mode.phrygianPentatonic.id == "10")
    }
    
    @Test func testIntervalClasses() async throws {
        #expect(Mode.ionian.intervalClasses == [."P1", .two, .four, .five, .seven, .nine, .eleven])
        #expect(Mode.ionianPentatonic.intervalClasses == [."P1", .two, .four, .seven, .nine])
        
        #expect(Mode.phrygian.intervalClasses == [."P1", .one, .three, .five, .seven, .eight, .ten])
        #expect(Mode.phrygianPentatonic.intervalClasses == [."P1", .three, .five, .eight, .ten])
        
        #expect(Mode.aeolian.intervalClasses == [."P1", .two, .three, .five, .seven, .eight, .ten])
        #expect(Mode.aeolianPentatonic.intervalClasses == [."P1", .three, .five, .seven, .ten])
        
        #expect(Mode.mixolydian.intervalClasses == [."P1", .two, .four, .five, .seven, .nine, .ten])
        #expect(Mode.mixolydianPentatonic.intervalClasses == [."P1", .two, .five, .seven, .nine])

        #expect(Mode.dorian.intervalClasses == [."P1", .two, .three, .five, .seven, .nine, .ten])
        #expect(Mode.dorianPentatonic.intervalClasses == [."P1", .two, .five, .seven, .ten])
        
        #expect(Mode.lydian.intervalClasses == [."P1", .two, .four, .six, .seven, .nine, .eleven])
        #expect(Mode.locrian.intervalClasses == [."P1", .one, .three, .five, .six, .eight, .ten])

    }

    final class ScaleTests {
        @Test func testId() async throws {
            #expect(Scale.pentatonic.id == "5")
        }

        @Test func testIcon() async throws {
            #expect(Scale.heptatonic.icon == "7.square")
            #expect(Scale.pentatonic.icon == "pentagon.fill")
        }
        
        @Test func testComparison() async throws {
            #expect((Scale.pentatonic < Scale.heptatonic) == true)
        }

    }
}
