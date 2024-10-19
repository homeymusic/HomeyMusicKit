import Testing
import SwiftUI
import MIDIKitCore

@testable import HomeyMusicKit

final class PitchTests {
    
    @Test func testPitchEquality() async throws {
        let pitch1 = Pitch.pitch(for: 60)  // C4
        let pitch2 = Pitch.pitch(for: 60)  // C4
        let pitch3 = Pitch.pitch(for: 61)  // C#4
        
        // Test equality
        #expect(pitch1 == pitch2)
        #expect(pitch1 != pitch3)
    }
    
    @Test func testPitchComparison() async throws {
        let pitch1 = Pitch.pitch(for: 60)  // C4
        let pitch2 = Pitch.pitch(for: 61)  // C#4
        
        // Test comparison
        #expect(pitch1 < pitch2)
    }
    
    @Test func testPitchActivation() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Activate pitch
        pitch.activate()
        #expect(pitch.isActivated == true)
        
        // Deactivate pitch
        pitch.deactivate()
        #expect(pitch.isActivated == false)
    }
    
    @Test func testIntervalCalculation() async throws {
        let c4 = Pitch.pitch(for: 60)  // C4
        let g4 = Pitch.pitch(for: 67)  // G4
        
        // Test interval calculation
        let interval = c4.interval(from: g4)
        #expect(interval.distance == -7)
    }
    
    @Test func testDistanceCalculation() async throws {
        let c4 = Pitch.pitch(for: 60)  // C4
        let g4 = Pitch.pitch(for: 67)  // G4
        
        // Test distance in semitones
        let distance = c4.distance(from: g4)
        #expect(distance == -7)
    }
    
    @Test func testActivatedPitches() async throws {
        let pitch1 = Pitch.pitch(for: 60)  // C4
        let pitch2 = Pitch.pitch(for: 61)  // C#4

        pitch1.activate()
        pitch2.activate()

        let activated = Pitch.activatedPitches
        #expect(activated.contains(pitch1))
        #expect(activated.contains(pitch2))
    }

    @Test func testIsOctave() async throws {
        let c4 = Pitch.pitch(for: 60)  // C4
        let c5 = Pitch.pitch(for: 72)  // C5
        
        // Test octave relation
        #expect(c4.isOctave(relativeTo: c5))
    }
    
    @Test func testOctaveValue() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Test octave value
        #expect(pitch.octave == 4)
    }
    
    @Test func testFundamentalFrequency() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Test fundamental frequency for C4 (should be around 261.63 Hz)
        let expectedFrequency: Double = 261.63
        #expect(abs(pitch.fundamentalFrequency - expectedFrequency) < 0.1)
    }
    
    @Test func testWavelength() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Test wavelength (C4 has a wavelength of around 1.31 meters in air)
        let expectedWavelength: Double = 1.31
        #expect(abs(pitch.wavelength - expectedWavelength) < 0.1)
    }
    
    @Test func testCochleaPositions() async throws {
        let lowPitch = Pitch.pitch(for: 0)
        // Test cochlea position (C4 should return a position around 35.85)
        let lowPitchExpectedPosition: Double = 101.5
        #expect(abs(lowPitch.cochlea - lowPitchExpectedPosition) < 0.1)

        let mediumPitch = Pitch.pitch(for: 60)
        // Test cochlea position (C4 should return a position around 35.85)
        let mediumPitchExpectedPosition: Double = 81.4
        #expect(abs(mediumPitch.cochlea - mediumPitchExpectedPosition) < 0.1)

        let highPitch = Pitch.pitch(for: 127)
        // Test cochlea position (C4 should return a position around 35.85)
        let highPitchExpectedPosition: Double = 10.3
        #expect(abs(highPitch.cochlea - highPitchExpectedPosition) < 0.1)

    }
    
    @Test func testAccidental() async throws {
        let pitch = Pitch.pitch(for: 61)  // C#4
        let naturalPitch = Pitch.pitch(for: 60)  // C4
        
        // Test accidental detection
        #expect(pitch.accidental == true)
        #expect(naturalPitch.accidental == false)
    }
    
    @Test func testPitchClassLetter() async throws {
        let pitch = Pitch.pitch(for: 61)  // C#4
        
        // Test letter name for C#4
        #expect(pitch.letter(.sharp) == "C♯")
    }
    
    @Test func testFixedDo() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Test Fixed Do for C4
        #expect(pitch.fixedDo(.sharp) == "Do")
    }
    
    @Test func testPitchComparisonOperators() async throws {
        let pitch1 = Pitch.pitch(for: 60)  // C4
        let pitch2 = Pitch.pitch(for: 61)  // C#4
        
        // Test pitch comparison operators
        #expect(pitch1 < pitch2)
        #expect(pitch2 > pitch1)
    }
}
