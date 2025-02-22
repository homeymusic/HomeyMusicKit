import Testing
import SwiftUI
import MIDIKitCore
import MIDIKitIO
import AVFoundation
import DunneAudioKit
import AudioKit

@testable import HomeyMusicKit

final class PitchTests {
    
    @Test func testIsValidPitch() async throws {
        #expect(Pitch.isValidPitch(60)  == true)
        #expect(Pitch.isValidPitch(-1)  == false)
        #expect(Pitch.isValidPitch(128) == false)
    }
    
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
    
    @MainActor
    @Test func testPitchActivation() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        
        // Activate pitch
        pitch.activate()
        #expect(pitch.isActivated.value == true)
        
        // Deactivate pitch
        pitch.deactivate()
        #expect(pitch.isActivated.value == false)
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
        #expect(pitch.isNatural == false)
        #expect(naturalPitch.isNatural == true)
    }
    
    @Test func testPitchClassLetter() async throws {
        let pitch = Pitch.pitch(for: 61)  // C#4
        
        // Test letter name for C#4
        #expect(pitch.letter(.sharp) == "C♯")
    }
    
    @Test func testFixedDo() async throws {
        let pitchFSharp = Pitch.pitch(for: 66)  // F#
        let pitchGFlat = Pitch.pitch(for: 66)   // F# treated as Gb
        #expect(pitchFSharp.fixedDo(.sharp) == "Fa♯")
        #expect(pitchGFlat.fixedDo(.flat) == "Sol♭")
        
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
    
    @MainActor
    @Test func testDeactivateAllPitches() async throws {
        Pitch.allPitches.forEach { $0.activate() }  // Activate all for test setup
        Pitch.deactivateAllPitches()
        
        #expect(Pitch.allPitches.allSatisfy { !$0.isActivated.value } == true)
    }
    
    @MainActor
    @Test func testPitchActivationInTonalContext() async throws {
        Pitch.deactivateAllPitches()
        
        let pitch = Pitch.pitch(for: 60)  // C4
        pitch.activate()
        
        #expect(TonalContext.shared.activatedPitches.contains(pitch))
        
        pitch.deactivate()
        
        #expect(!TonalContext.shared.activatedPitches.contains(pitch))
    }
    
    @Test func testWavenumber() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        let expectedWavenumber = 1 / pitch.wavelength
        #expect(pitch.wavenumber == expectedWavenumber)
    }
    
    @Test func testIntValue() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        #expect(pitch.intValue == 60)
    }
    
    @Test func testLetter() async throws {
        let pitchCSharp = Pitch.pitch(for: 61)  // C#4
        let pitchDFlat = Pitch.pitch(for: 61)   // C#4, treated as Db
        #expect(pitchCSharp.letter(.sharp) == "C♯")
        #expect(pitchDFlat.letter(.flat) == "D♭")
    }
    
    
    @Test func testMode() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4, which is in "Ionian" mode by default
        #expect(pitch.mode == .ionian)
    }
    
    @Test func testOctave() async throws {
        let pitch = Pitch.pitch(for: 60)  // C4
        #expect(pitch.octave == 4)
    }
    
    @Test func testLetterFunction() async throws {
        // Test each pitch class with both sharp and flat accidentals
        let pitchC = Pitch.pitch(for: 60)  // C4
        #expect(pitchC.letter(.sharp) == "C")
        #expect(pitchC.letter(.flat) == "C")
        
        let pitchCSharp = Pitch.pitch(for: 61)  // C#4
        #expect(pitchCSharp.letter(.sharp) == "C♯")
        #expect(pitchCSharp.letter(.flat) == "D♭")
        
        let pitchD = Pitch.pitch(for: 62)  // D4
        #expect(pitchD.letter(.sharp) == "D")
        #expect(pitchD.letter(.flat) == "D")
        
        let pitchDSharp = Pitch.pitch(for: 63)  // D#4
        #expect(pitchDSharp.letter(.sharp) == "D♯")
        #expect(pitchDSharp.letter(.flat) == "E♭")
        
        let pitchE = Pitch.pitch(for: 64)  // E4
        #expect(pitchE.letter(.sharp) == "E")
        #expect(pitchE.letter(.flat) == "E")
        
        let pitchF = Pitch.pitch(for: 65)  // F4
        #expect(pitchF.letter(.sharp) == "F")
        #expect(pitchF.letter(.flat) == "F")
        
        let pitchFSharp = Pitch.pitch(for: 66)  // F#4
        #expect(pitchFSharp.letter(.sharp) == "F♯")
        #expect(pitchFSharp.letter(.flat) == "G♭")
        
        let pitchG = Pitch.pitch(for: 67)  // G4
        #expect(pitchG.letter(.sharp) == "G")
        #expect(pitchG.letter(.flat) == "G")
        
        let pitchGSharp = Pitch.pitch(for: 68)  // G#4
        #expect(pitchGSharp.letter(.sharp) == "G♯")
        #expect(pitchGSharp.letter(.flat) == "A♭")
        
        let pitchA = Pitch.pitch(for: 69)  // A4
        #expect(pitchA.letter(.sharp) == "A")
        #expect(pitchA.letter(.flat) == "A")
        
        let pitchASharp = Pitch.pitch(for: 70)  // A#4
        #expect(pitchASharp.letter(.sharp) == "A♯")
        #expect(pitchASharp.letter(.flat) == "B♭")
        
        let pitchB = Pitch.pitch(for: 71)  // B4
        #expect(pitchB.letter(.sharp) == "B")
        #expect(pitchB.letter(.flat) == "B")
    }
    
    @Test func testFixedDoFunction() async throws {
        // Test each pitch class with both sharp and flat accidentals
        let pitchC = Pitch.pitch(for: 60)  // C4
        #expect(pitchC.fixedDo(.sharp) == "Do")
        #expect(pitchC.fixedDo(.flat) == "Do")
        
        let pitchCSharp = Pitch.pitch(for: 61)  // C#4
        #expect(pitchCSharp.fixedDo(.sharp) == "Do♯")
        #expect(pitchCSharp.fixedDo(.flat) == "Re♭")
        
        let pitchD = Pitch.pitch(for: 62)  // D4
        #expect(pitchD.fixedDo(.sharp) == "Re")
        #expect(pitchD.fixedDo(.flat) == "Re")
        
        let pitchDSharp = Pitch.pitch(for: 63)  // D#4
        #expect(pitchDSharp.fixedDo(.sharp) == "Re♯")
        #expect(pitchDSharp.fixedDo(.flat) == "Mi♭")
        
        let pitchE = Pitch.pitch(for: 64)  // E4
        #expect(pitchE.fixedDo(.sharp) == "Mi")
        #expect(pitchE.fixedDo(.flat) == "Mi")
        
        let pitchF = Pitch.pitch(for: 65)  // F4
        #expect(pitchF.fixedDo(.sharp) == "Fa")
        #expect(pitchF.fixedDo(.flat) == "Fa")
        
        let pitchFSharp = Pitch.pitch(for: 66)  // F#4
        #expect(pitchFSharp.fixedDo(.sharp) == "Fa♯")
        #expect(pitchFSharp.fixedDo(.flat) == "Sol♭")
        
        let pitchG = Pitch.pitch(for: 67)  // G4
        #expect(pitchG.fixedDo(.sharp) == "Sol")
        #expect(pitchG.fixedDo(.flat) == "Sol")
        
        let pitchGSharp = Pitch.pitch(for: 68)  // G#4
        #expect(pitchGSharp.fixedDo(.sharp) == "Sol♯")
        #expect(pitchGSharp.fixedDo(.flat) == "La♭")
        
        let pitchA = Pitch.pitch(for: 69)  // A4
        #expect(pitchA.fixedDo(.sharp) == "La")
        #expect(pitchA.fixedDo(.flat) == "La")
        
        let pitchASharp = Pitch.pitch(for: 70)  // A#4
        #expect(pitchASharp.fixedDo(.sharp) == "La♯")
        #expect(pitchASharp.fixedDo(.flat) == "Si♭")
        
        let pitchB = Pitch.pitch(for: 71)  // B4
        #expect(pitchB.fixedDo(.sharp) == "Si")
        #expect(pitchB.fixedDo(.flat) == "Si")
    }
    
    @Test func testMockMIDIConductorSendNoteOn() async throws {
        let mockMIDIConductor = MockMIDIConductor()
        let midiNote = MIDINote(60)
        let midiChannel: UInt4 = 0

        mockMIDIConductor.noteOn(midiNote: midiNote, midiChannel: midiChannel)
        
        #expect(mockMIDIConductor.noteOn == true)
    }

    @Test func testMockMIDIConductorSendNoteOff() async throws {
        let mockMIDIConductor = MockMIDIConductor()
        let midiNote = MIDINote(60)
        let midiChannel: UInt4 = 0

        mockMIDIConductor.noteOn(midiNote: midiNote, midiChannel: midiChannel)
        mockMIDIConductor.noteOff(midiNote: midiNote, midiChannel: midiChannel)
        
        #expect(mockMIDIConductor.noteOn == false)
    }

    @Test func testMockMIDIConductorSendTonicPitch() async throws {
        let mockMIDIConductor = MockMIDIConductor()
        let midiNote = MIDINote(60)
        let midiChannel: UInt4 = 0

        mockMIDIConductor.tonicPitch(midiNote: midiNote, midiChannel: midiChannel)
        
        #expect(mockMIDIConductor.sentTonicPitch == true)
    }

    @Test func testMockMIDIConductorSendPitchDirection() async throws {
        let mockMIDIConductor = MockMIDIConductor()
        let midiChannel: UInt4 = 0

        mockMIDIConductor.pitchDirection(upwardPitchDirection: true, midiChannel: midiChannel)
        
        #expect(mockMIDIConductor.sentPitchDirection == true)
    }
    @Test func testMockSynthConductorNoteOn() async throws {
        let mockSynthConductor = MockSynthConductor()
        let midiNote = MIDINote(60)

        mockSynthConductor.noteOn(midiNote: midiNote)
        
        #expect(mockSynthConductor.noteOn == true)
    }

    @Test func testMockSynthConductorNoteOff() async throws {
        let mockSynthConductor = MockSynthConductor()
        let midiNote = MIDINote(60)

        mockSynthConductor.noteOn(midiNote: midiNote)
        mockSynthConductor.noteOff(midiNote: midiNote)
        
        #expect(mockSynthConductor.noteOn == false)
    }

    @Test func testMockSynthConductorStart() async throws {
        let mockSynthConductor = MockSynthConductor()

        mockSynthConductor.start()
        
        #expect(mockSynthConductor.started == true)
    }
    
    @Test func testSpeedOfSound() async throws {
        #expect(Pitch.speedOfSound == MIDINote.calculateFrequency(midiNote: 65))
    }
    
    @Test func testWavelengthOfF4IsOne() async throws {
        #expect(Pitch.pitch(for: 65).wavelength == 1)
    }

}

class MockMIDIConductor: MIDIConductorProtocol {
    var noteOn = false
    var sentTonicPitch = false
    var sentPitchDirection = false
    
    func setup(midiManager: ObservableMIDIManager) {
    }
    
    public func noteOn(midiNote: MIDINote, midiChannel: UInt4) {
        noteOn = true
    }
    
    public func noteOff(midiNote: MIDINote, midiChannel: UInt4) {
        noteOn = false
    }
    
    func tonicPitch(midiNote: MIDINote, midiChannel: UInt4) {
        sentTonicPitch = true
    }
    
    func pitchDirection(upwardPitchDirection: Bool, midiChannel: UInt4) {
        sentPitchDirection = true
    }

}

class MockSynthConductor: SynthConductorProtocol {
    var noteOn = false
    var started = false
    let engine: AudioEngine = AudioEngine()

    func noteOn(midiNote: MIDINote) {
        noteOn = true
    }
    
    func noteOff(midiNote: MIDINote) {
        noteOn = false
    }
    
    func start() {
        started = true
    }
}
