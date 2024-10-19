import Testing
@testable import HomeyMusicKit

final class TonalContextTests {

    @MainActor
    @Test func testShiftUpOneOctave() async throws {
        let tonalContext = TonalContext.shared
        let originalTonic = tonalContext.tonicPitch
        tonalContext.shiftUpOneOctave()
        
        let expectedTonic = Pitch.pitch(for: originalTonic.midiNote.number + 12)
        #expect(tonalContext.tonicPitch == expectedTonic)
    }

    @MainActor
    @Test func testShiftDownOneOctave() async throws {
        let tonalContext = TonalContext.shared
        let originalTonic = tonalContext.tonicPitch
        tonalContext.shiftDownOneOctave()
        
        let expectedTonic = Pitch.pitch(for: originalTonic.midiNote.number - 12)
        #expect(tonalContext.tonicPitch == expectedTonic)
    }

    @MainActor
    @Test func testResetTonicPitch() async throws {
        let tonalContext = TonalContext.shared
        tonalContext.tonicPitch = Pitch.pitch(for: 64)
        tonalContext.resetTonicPitch()
        
        let defaultTonic = Pitch.pitch(for: Pitch.defaultTonicMIDI)
        #expect(tonalContext.tonicPitch == defaultTonic)
    }

    @MainActor
    @Test func testResetPitchDirection() async throws {
        let tonalContext = TonalContext.shared
        tonalContext.pitchDirection = .upward
        tonalContext.resetPitchDirection()
        
        #expect(tonalContext.pitchDirection == .default)
    }

    @MainActor
    @Test func testCanShiftUpOneOctave() async throws {
        let tonalContext = TonalContext.shared
        tonalContext.tonicPitch = Pitch.pitch(for: 116)
        
        let canShift = tonalContext.canShiftUpOneOctave
        #expect(canShift == false)
    }

    @MainActor
    @Test func testCanShiftDownOneOctave() async throws {
        let tonalContext = TonalContext.shared
        tonalContext.tonicPitch = Pitch.pitch(for: 11)
        
        let canShift = tonalContext.canShiftDownOneOctave
        #expect(canShift == false)
    }
}
