import Testing
@testable import HomeyMusicKit

final class PitchClassTests {
    
    @Test func testPitchClassInitialization() async throws {
        let pitchClass = PitchClass(noteNumber: 14)  // 14 mod 12 == 2
        #expect(pitchClass == .two)
        
        let anotherPitchClass = PitchClass(noteNumber: -1)  // -1 mod 12 == 11
        #expect(anotherPitchClass == .eleven)
    }

    @Test func testIntValue() async throws {
        let pitchClass = PitchClass.five
        #expect(pitchClass.intValue == 5)
    }
    
    @Test func testStringValue() async throws {
        let pitchClass = PitchClass.ten
        #expect(pitchClass.stringValue == "10")
    }
    
    @Test func testIsActivated() async throws {
        // Assuming Pitch.activatedPitches is properly set up in the test environment
        let pitchClass = PitchClass.four
        #expect(pitchClass.isActivated == false)  // Assuming no pitch in this class is activated
        
        // Activate a pitch in the class (this step will depend on how Pitch is handled in your project)
        let pitch = Pitch.pitch(for: 64)  // Example: E (MIDI 64, which maps to PitchClass.four)
        pitch.activate()
        
        #expect(pitchClass.isActivated == true)
    }
    
    @Test func testPitchClassComparison() async throws {
        let lowerPitchClass = PitchClass.two
        let higherPitchClass = PitchClass.eight
        #expect(lowerPitchClass < higherPitchClass)
    }
}
