import Testing
import MIDIKitCore
import Foundation
@testable import HomeyMusicKit

@MainActor
final class TonalContextDefaultsManagerTests {
    let defaultsManager = TonalContextDefaultsManager()
    let defaults = UserDefaults.standard
    let allPitches = Pitch.allPitches  // Assuming this is already properly initialized

    @Test func testLoadStateWithDefaultValues() async throws {
        // Clear UserDefaults to simulate first-time run (or no saved data)
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()

        // Expected: Default tonic and pitch direction
        let result = defaultsManager.loadState(allPitches: allPitches)

        #expect(result.tonicPitch == Pitch.pitch(for: Pitch.defaultTonicMIDI))  // Default tonic pitch
        #expect(result.pitchDirection == .upward)  // Default direction if no data
    }

    @Test func testLoadStateWithSavedValues() async throws {
        // Simulate saving a value in UserDefaults
        defaults.set(64, forKey: "tonicMIDI")  // MIDI note 64 (E)
        defaults.set(-1, forKey: "pitchDirection")  // PitchDirection.downward

        let result = defaultsManager.loadState(allPitches: allPitches)

        #expect(result.tonicPitch == Pitch.pitch(for: 64))  // Expect saved tonic pitch
        #expect(result.pitchDirection == .downward)  // Expect saved pitch direction
    }

    @Test func testSaveState() async throws {
        // Create a test tonicPitch and pitchDirection
        let testPitch = Pitch.pitch(for: 65)  // Example: MIDI note 65
        let testDirection: PitchDirection = .downward
        let testModeOffset: Mode = .ionian

        // Save the state
        defaultsManager.saveState(tonicPitch: testPitch, modeOffset: testModeOffset, pitchDirection: testDirection)

        // Verify that the saved values match
        let savedTonicMIDI = defaults.integer(forKey: "tonicMIDI")
        let savedPitchDirection = defaults.integer(forKey: "pitchDirection")
        let savedModeOffset = defaults.integer(forKey: "modeOffset")

        #expect(savedTonicMIDI == 65)  // Saved tonicMIDI should be 65
        #expect(savedPitchDirection == -1)  // Saved pitchDirection should be downward (-1)
        #expect(savedModeOffset == 0)  // Saved pitchDirection should be downward (-1)
    }
}
