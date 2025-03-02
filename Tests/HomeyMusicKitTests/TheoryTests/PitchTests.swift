import Testing
import SwiftUI
import MIDIKitCore
import MIDIKitIO
import AVFoundation

@testable import HomeyMusicKit

final class PitchTests {
    
    let tonalContext = TonalContext(
        clientName: "TestApp",
        model: "Test",
        manufacturer: "Testing"
    )
    
    lazy var midiConductor = MIDIConductor(
        tonalContext: tonalContext
    )

    @Test func testIsValidPitch() async throws {
        #expect(Pitch.isValid(60)  == true)
        #expect(Pitch.isValid(-1)  == false)
        #expect(Pitch.isValid(128) == false)
    }
    
    @Test func testPitchEquality() async throws {
        let pitch1 = tonalContext.pitch(for: 60)  // C4
        let pitch2 = tonalContext.pitch(for: 60)  // C4
        let pitch3 = tonalContext.pitch(for: 61)  // C#4
        
        // Test equality
        #expect(pitch1 == pitch2)
        #expect(pitch1 != pitch3)
    }
    
    @Test func testPitchComparison() async throws {
        let pitch1 = tonalContext.pitch(for: 60)  // C4
        let pitch2 = tonalContext.pitch(for: 61)  // C#4
        
        // Test comparison
        #expect(pitch1 < pitch2)
    }
    
    @MainActor
    @Test func testPitchActivation() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        
        // Activate pitch
        pitch.activate()
        #expect(pitch.isActivated == true)
        
        // Deactivate pitch
        pitch.deactivate()
        #expect(pitch.isActivated == false)
    }
    
    @Test func testIntervalCalculation() async throws {
        let c4 = tonalContext.pitch(for: 60)  // C4
        let g4 = tonalContext.pitch(for: 67)  // G4
        
        // Test interval calculation
        let distance = c4.distance(from: g4)
        #expect(distance == -7)
    }
    
    @Test func testDistanceCalculation() async throws {
        let c4 = tonalContext.pitch(for: 60)  // C4
        let g4 = tonalContext.pitch(for: 67)  // G4
        
        // Test distance in semitones
        let distance = c4.distance(from: g4)
        #expect(distance == -7)
    }
        
    @Test func testOctaveValue() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        
        // Test octave value
        #expect(pitch.octave == 4)
    }
    
    @Test func testFundamentalFrequency() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        
        // Test fundamental frequency for C4 (should be around 261.63 Hz)
        let expectedFrequency: Double = 261.63
        #expect(abs(pitch.fundamentalFrequency - expectedFrequency) < 0.1)
    }
    
    @Test func testWavelength() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        
        // Test wavelength (C4 has a wavelength of around 1.31 meters in air)
        let expectedWavelength: Double = 1.31
        #expect(abs(pitch.wavelength - expectedWavelength) < 0.1)
    }
    
    @Test func testCochleaPositions() async throws {
        let lowPitch = tonalContext.pitch(for: 0)
        // Test cochlea position (C4 should return a position around 35.85)
        let lowPitchExpectedPosition: Double = 101.5
        #expect(abs(lowPitch.cochlea - lowPitchExpectedPosition) < 0.1)
        
        let mediumPitch = tonalContext.pitch(for: 60)
        // Test cochlea position (C4 should return a position around 35.85)
        let mediumPitchExpectedPosition: Double = 81.4
        #expect(abs(mediumPitch.cochlea - mediumPitchExpectedPosition) < 0.1)
        
        let highPitch = tonalContext.pitch(for: 127)
        // Test cochlea position (C4 should return a position around 35.85)
        let highPitchExpectedPosition: Double = 10.3
        #expect(abs(highPitch.cochlea - highPitchExpectedPosition) < 0.1)
        
    }
    
    @Test func testAccidental() async throws {
        let pitch = tonalContext.pitch(for: 61)  // C#4
        let naturalPitch = tonalContext.pitch(for: 60)  // C4
        
        // Test accidental detection
        #expect(pitch.isNatural == false)
        #expect(naturalPitch.isNatural == true)
    }
    
    @Test func testPitchClassLetter() async throws {
        let pitch = tonalContext.pitch(for: 61)  // C#4
        
        // Test letter name for C#4
        #expect(pitch.letter(using: .sharp) == "C♯")
    }
    
    @Test func testFixedDo() async throws {
        let pitchFSharp = tonalContext.pitch(for: 66)  // F#
        let pitchGFlat = tonalContext.pitch(for: 66)   // F# treated as Gb
        #expect(pitchFSharp.fixedDo(using: .sharp) == "Fa♯")
        #expect(pitchGFlat.fixedDo(using: .flat) == "Sol♭")
        
        let pitch = tonalContext.pitch(for: 60)  // C4
        
        // Test Fixed Do for C4
        #expect(pitch.fixedDo(using: .sharp) == "Do")
    }
    
    @Test func testPitchComparisonOperators() async throws {
        let pitch1 = tonalContext.pitch(for: 60)  // C4
        let pitch2 = tonalContext.pitch(for: 61)  // C#4
        
        // Test pitch comparison operators
        #expect(pitch1 < pitch2)
        #expect(pitch2 > pitch1)
    }
    
    @MainActor
    @Test func testDeactivateAllPitches() async throws {
        tonalContext.allPitches.forEach { $0.activate() }  // Activate all for test setup
        tonalContext.deactivateAllPitches()
        
        #expect(tonalContext.allPitches.allSatisfy { !$0.isActivated } == true)
    }
    
    @MainActor
    @Test func testPitchActivationInTonalContext() async throws {
        tonalContext.deactivateAllPitches()
        
        let pitch = tonalContext.pitch(for: 60)  // C4
        pitch.activate()
        
        #expect(pitch.isActivated)
        
        pitch.deactivate()
        
        #expect(!pitch.isActivated)
    }
    
    @Test func testWavenumber() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        let expectedWavenumber = 1 / pitch.wavelength
        #expect(pitch.wavenumber == expectedWavenumber)
    }
    
    @Test func testIntValue() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        #expect(pitch.intValue == 60)
    }
    
    @Test func testLetter() async throws {
        let pitchCSharp = tonalContext.pitch(for: 61)  // C#4
        let pitchDFlat = tonalContext.pitch(for: 61)   // C#4, treated as Db
        #expect(pitchCSharp.letter(using: .sharp) == "C♯")
        #expect(pitchDFlat.letter(using: .flat) == "D♭")
    }
    
        
    @Test func testOctave() async throws {
        let pitch = tonalContext.pitch(for: 60)  // C4
        #expect(pitch.octave == 4)
    }
    
    @Test func testLetterFunction() async throws {
        // Test each pitch class with both sharp and flat accidentals
        let pitchC = tonalContext.pitch(for: 60)  // C4
        #expect(pitchC.letter(using: .sharp) == "C")
        #expect(pitchC.letter(using: .flat) == "C")
        
        let pitchCSharp = tonalContext.pitch(for: 61)  // C#4
        #expect(pitchCSharp.letter(using: .sharp) == "C♯")
        #expect(pitchCSharp.letter(using: .flat) == "D♭")
        
        let pitchD = tonalContext.pitch(for: 62)  // D4
        #expect(pitchD.letter(using: .sharp) == "D")
        #expect(pitchD.letter(using: .flat) == "D")
        
        let pitchDSharp = tonalContext.pitch(for: 63)  // D#4
        #expect(pitchDSharp.letter(using: .sharp) == "D♯")
        #expect(pitchDSharp.letter(using: .flat) == "E♭")
        
        let pitchE = tonalContext.pitch(for: 64)  // E4
        #expect(pitchE.letter(using: .sharp) == "E")
        #expect(pitchE.letter(using: .flat) == "E")
        
        let pitchF = tonalContext.pitch(for: 65)  // F4
        #expect(pitchF.letter(using: .sharp) == "F")
        #expect(pitchF.letter(using: .flat) == "F")
        
        let pitchFSharp = tonalContext.pitch(for: 66)  // F#4
        #expect(pitchFSharp.letter(using: .sharp) == "F♯")
        #expect(pitchFSharp.letter(using: .flat) == "G♭")
        
        let pitchG = tonalContext.pitch(for: 67)  // G4
        #expect(pitchG.letter(using: .sharp) == "G")
        #expect(pitchG.letter(using: .flat) == "G")
        
        let pitchGSharp = tonalContext.pitch(for: 68)  // G#4
        #expect(pitchGSharp.letter(using: .sharp) == "G♯")
        #expect(pitchGSharp.letter(using: .flat) == "A♭")
        
        let pitchA = tonalContext.pitch(for: 69)  // A4
        #expect(pitchA.letter(using: .sharp) == "A")
        #expect(pitchA.letter(using: .flat) == "A")
        
        let pitchASharp = tonalContext.pitch(for: 70)  // A#4
        #expect(pitchASharp.letter(using: .sharp) == "A♯")
        #expect(pitchASharp.letter(using: .flat) == "B♭")
        
        let pitchB = tonalContext.pitch(for: 71)  // B4
        #expect(pitchB.letter(using: .sharp) == "B")
        #expect(pitchB.letter(using: .flat) == "B")
    }
    
    @Test func testFixedDoFunction() async throws {
        // Test each pitch class with both sharp and flat accidentals
        let pitchC = tonalContext.pitch(for: 60)  // C4
        #expect(pitchC.fixedDo(using: .sharp) == "Do")
        #expect(pitchC.fixedDo(using: .flat) == "Do")
        
        let pitchCSharp = tonalContext.pitch(for: 61)  // C#4
        #expect(pitchCSharp.fixedDo(using: .sharp) == "Do♯")
        #expect(pitchCSharp.fixedDo(using: .flat) == "Re♭")
        
        let pitchD = tonalContext.pitch(for: 62)  // D4
        #expect(pitchD.fixedDo(using: .sharp) == "Re")
        #expect(pitchD.fixedDo(using: .flat) == "Re")
        
        let pitchDSharp = tonalContext.pitch(for: 63)  // D#4
        #expect(pitchDSharp.fixedDo(using: .sharp) == "Re♯")
        #expect(pitchDSharp.fixedDo(using: .flat) == "Mi♭")
        
        let pitchE = tonalContext.pitch(for: 64)  // E4
        #expect(pitchE.fixedDo(using: .sharp) == "Mi")
        #expect(pitchE.fixedDo(using: .flat) == "Mi")
        
        let pitchF = tonalContext.pitch(for: 65)  // F4
        #expect(pitchF.fixedDo(using: .sharp) == "Fa")
        #expect(pitchF.fixedDo(using: .flat) == "Fa")
        
        let pitchFSharp = tonalContext.pitch(for: 66)  // F#4
        #expect(pitchFSharp.fixedDo(using: .sharp) == "Fa♯")
        #expect(pitchFSharp.fixedDo(using: .flat) == "Sol♭")
        
        let pitchG = tonalContext.pitch(for: 67)  // G4
        #expect(pitchG.fixedDo(using: .sharp) == "Sol")
        #expect(pitchG.fixedDo(using: .flat) == "Sol")
        
        let pitchGSharp = tonalContext.pitch(for: 68)  // G#4
        #expect(pitchGSharp.fixedDo(using: .sharp) == "Sol♯")
        #expect(pitchGSharp.fixedDo(using: .flat) == "La♭")
        
        let pitchA = tonalContext.pitch(for: 69)  // A4
        #expect(pitchA.fixedDo(using: .sharp) == "La")
        #expect(pitchA.fixedDo(using: .flat) == "La")
        
        let pitchASharp = tonalContext.pitch(for: 70)  // A#4
        #expect(pitchASharp.fixedDo(using: .sharp) == "La♯")
        #expect(pitchASharp.fixedDo(using: .flat) == "Si♭")
        
        let pitchB = tonalContext.pitch(for: 71)  // B4
        #expect(pitchB.fixedDo(using: .sharp) == "Si")
        #expect(pitchB.fixedDo(using: .flat) == "Si")
    }
    
    @Test func testmidiConductorSendNoteOn() async throws {
        let midiNoteNumber = MIDINoteNumber(60)
        let midiChannel: UInt4 = 0

        midiConductor.noteOn(pitch: tonalContext.pitch(for: midiNoteNumber), midiChannel: midiChannel)
        
    }

    @Test func testmidiConductorSendNoteOff() async throws {
        let midiNoteNumber = MIDINoteNumber(60)
        let midiChannel: UInt4 = 0

        midiConductor.noteOn(pitch: tonalContext.pitch(for: midiNoteNumber), midiChannel: midiChannel)
        midiConductor.noteOff(pitch: tonalContext.pitch(for: midiNoteNumber), midiChannel: midiChannel)
        
    }

    @Test func testmidiConductorSendTonicPitch() async throws {
        let midiNoteNumber = MIDINoteNumber(60)
        let midiChannel: UInt4 = 0

        midiConductor.tonicPitch(pitch: tonalContext.pitch(for: midiNoteNumber), midiChannel: midiChannel)
        
    }

    @Test func testmidiConductorSendPitchDirection() async throws {
        let midiChannel: UInt4 = 0

        midiConductor.pitchDirection(pitchDirection: PitchDirection.upward, midiChannel: midiChannel)
        
    }
    
    @Test func testWavelengthOfF4IsOne() async throws {
        #expect(tonalContext.pitch(for: 65).wavelength == 1)
    }

}

