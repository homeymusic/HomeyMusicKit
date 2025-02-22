import Testing
import SwiftUI

@testable import HomeyMusicKit

final class IntervalTests {
    
    @Test func testIsTonic() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let interval = Interval.interval(from: tonicPitch, to: tonicPitch)
        
        // Test if the interval is tonic (unison)
        #expect(interval.isTonic == true)
    }
    
    @Test func testIsTritone() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let tritonePitch = Pitch.pitch(for: 66)  // F#4
        let interval = Interval.interval(from: tonicPitch, to: tritonePitch)
        
        // Test if the interval is tritone
        #expect(interval.isTritone == true)
    }
    
    @Test func testIsOctave() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let octavePitch = Pitch.pitch(for: 72)  // C5
        let interval = Interval.interval(from: tonicPitch, to: octavePitch)
        
        // Test if the interval is an octave
        #expect(interval.isOctave == true)
    }
    
    @Test func testMajorMinor() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let minorThirdPitch = Pitch.pitch(for: 63)  // Eb4
        let majorThirdPitch = Pitch.pitch(for: 64)  // E4
        
        let minorInterval = Interval.interval(from: tonicPitch, to: minorThirdPitch)
        let majorInterval = Interval.interval(from: tonicPitch, to: majorThirdPitch)
        
        #expect(minorInterval.majorMinor == .minor)
        #expect(majorInterval.majorMinor == .major)
    }
    
    @Test func testConsonanceDissonance() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let perfectFifthPitch = Pitch.pitch(for: 67)  // G4
        let minorSecondPitch = Pitch.pitch(for: 61)  // Db4
        
        let consonantInterval = Interval.interval(from: tonicPitch, to: perfectFifthPitch)
        let dissonantInterval = Interval.interval(from: tonicPitch, to: minorSecondPitch)
        
        #expect(consonantInterval.consonanceDissonance == .perfect)
        #expect(dissonantInterval.consonanceDissonance == .dissonant)
    }
    
    @Test func testEmoji() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let interval = Interval.interval(from: tonicPitch, to: tonicPitch)
        
        // Test if the correct emoji is returned
        let expectedImage = Image("home_tortoise_tree", bundle: .module)
        #expect(interval.emoji == expectedImage)
    }
    
    @Test func testMovableDo() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let interval = Interval.interval(from: tonicPitch, to: tonicPitch)
        
        // Test if the movable Do is correct
        #expect(interval.movableDo == "Do")
    }
    
    // Pitch direction tests
    
    @Test func testDegreeWithPitchDirectionUpward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let minorThirdPitch = Pitch.pitch(for: 63)  // Eb4
        let interval = Interval.interval(from: tonicPitch, to: minorThirdPitch)
        
        let pitchDirection = PitchDirection.upward
        #expect(interval.degree(pitchDirection: pitchDirection) == "♭3̂")
    }
    
    @Test func testDegreeWithPitchDirectionDownward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let minorThirdPitch = Pitch.pitch(for: 63)  // Eb4
        let interval = Interval.interval(from: tonicPitch, to: minorThirdPitch)
        
        let pitchDirection = PitchDirection.downward
        #expect(interval.degree(pitchDirection: pitchDirection) == "<6̂")
    }
    
    @Test func testRomanWithPitchDirectionUpward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let perfectFourthPitch = Pitch.pitch(for: 65)  // F4
        let interval = Interval.interval(from: tonicPitch, to: perfectFourthPitch)
        
        let pitchDirection = PitchDirection.upward
        #expect(interval.roman(pitchDirection: pitchDirection) == "IV")
    }
    
    @Test func testRomanWithPitchDirectionDownward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let perfectFourthPitch = Pitch.pitch(for: 65)  // F4
        let interval = Interval.interval(from: tonicPitch, to: perfectFourthPitch)
        
        let pitchDirection = PitchDirection.downward
        #expect(interval.roman(pitchDirection: pitchDirection) == "<V")
    }
    
    @Test func testShorthandWithPitchDirectionUpward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let tritonePitch = Pitch.pitch(for: 66)  // F#4
        let interval = Interval.interval(from: tonicPitch, to: tritonePitch)
        
        let pitchDirection = PitchDirection.upward
        #expect(interval.shorthand(pitchDirection: pitchDirection) == "tt")
    }
    
    @Test func testShorthandWithPitchDirectionDownward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let tritonePitch = Pitch.pitch(for: 66)  // F#4
        let interval = Interval.interval(from: tonicPitch, to: tritonePitch)
        
        let pitchDirection = PitchDirection.downward
        #expect(interval.shorthand(pitchDirection: pitchDirection) == "<tt")
    }
    
    @Test func testLabelWithPitchDirectionUpward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let minorSixthPitch = Pitch.pitch(for: 69)  // Ab4
        let interval = Interval.interval(from: tonicPitch, to: minorSixthPitch)
        
        let pitchDirection = PitchDirection.upward
        #expect(interval.label(pitchDirection: pitchDirection) == "upward major sixth")
    }
    
    @Test func testLabelWithPitchDirectionDownward() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let minorSixthPitch = Pitch.pitch(for: 69)  // Ab4
        let interval = Interval.interval(from: tonicPitch, to: minorSixthPitch)
        
        let pitchDirection = PitchDirection.downward
        #expect(interval.label(pitchDirection: pitchDirection) == "downward major third")
    }
    
    @Test func testMajorMinorFunction() async throws {
        #expect(Interval.majorMinor(0) == .neutral)
        #expect(Interval.majorMinor(4) == .major)
        #expect(Interval.majorMinor(7) == .neutral)
        #expect(Interval.majorMinor(10) == .minor)
        #expect(Interval.majorMinor(-3) == .major)  // Testing with a negative distance
    }
    
    // MARK: - Testing Wavelength Ratio
    
    @Test func testWavelengthRatio() async throws {
        let interval = Interval.allIntervals[4]!  // Interval distance of 4
        let expectedRatio = "λ " + String(decimalToFraction(1 / interval.f_ratio))
        #expect(interval.wavelengthRatio == expectedRatio)
    }
    
    // MARK: - Testing Wavenumber Ratio
    
    @Test func testWavenumberRatio() async throws {
        let interval = Interval.allIntervals[4]!  // Interval distance of 4
        let expectedRatio = "k " + String(decimalToFraction(interval.f_ratio))
        #expect(interval.wavenumberRatio == expectedRatio)
    }
    
    // MARK: - Testing Period Ratio
    
    @Test func testPeriodRatio() async throws {
        let interval = Interval.allIntervals[4]!  // Interval distance of 4
        let expectedRatio = "T " + String(decimalToFraction(1 / interval.f_ratio))
        #expect(interval.periodRatio == expectedRatio)
    }
    
    // MARK: - Testing Frequency Ratio
    
    @Test func testFrequencyRatio() async throws {
        let interval = Interval.allIntervals[4]!  // Interval distance of 4
        let expectedRatio = "f " + String(decimalToFraction(interval.f_ratio))
        #expect(interval.frequencyRatio == expectedRatio)
    }
    
    @Test func testSomeRatios() async throws {
        let tonicPitch = Pitch.pitch(for: 60)  // C4
        let p4Pitch = Pitch.pitch(for: 65)
        let p4interval = Interval.interval(from: tonicPitch, to: p4Pitch)
        
        // Test if the interval is tritone
        #expect(p4interval.frequencyRatio == "f 4:3")

        let p5Pitch = Pitch.pitch(for: 67)
        let p5interval = Interval.interval(from: tonicPitch, to: p5Pitch)
        
        // Test if the interval is tritone
        #expect(p5interval.frequencyRatio == "f 3:2")

        let p12Pitch = Pitch.pitch(for: 67 + 12)
        let p12interval = Interval.interval(from: tonicPitch, to: p12Pitch)
        
        // Test if the interval is tritone
        #expect(p12interval.frequencyRatio == "f 3:1")
    }

}
