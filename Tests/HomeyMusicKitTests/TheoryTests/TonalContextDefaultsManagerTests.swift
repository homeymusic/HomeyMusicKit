import Testing
import MIDIKitCore
import Foundation
@testable import HomeyMusicKit

@MainActor
final class TonalContextDefaultsManagerTests {
    let tonalContext = TonalContext(
        clientName: "TestApp",
        model: "Test",
        manufacturer: "Testing"
    )
    
    lazy var midiConductor = MIDIContext(
        tonalContext: tonalContext
    )
    
    func setupContext() {
        tonalContext.resetToDefault()
    }

    let defaultsManager = DefaultsManager()
    let defaults = UserDefaults.standard
    let allPitches = Pitch.allPitches()  // Assuming this is already properly initialized

    @Test func testLoadStateWithDefaultValues() async throws {
        // Clear UserDefaults to simulate first-time run (or no saved data)
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()

        // Expected: Default tonic and pitch direction
        let result = defaultsManager.loadState(allPitches: allPitches)

        #expect(result.tonicPitch == tonalContext.pitch(for: Pitch.defaultTonicMIDINoteNumber))  // Default tonic pitch
        #expect(result.pitchDirection == .upward)  // Default direction if no data
    }

    @Test func testLoadStateWithSavedValues() async throws {
        // Simulate saving a value in UserDefaults
        defaults.set(64, forKey: "tonicMIDI")  // MIDI note 64 (E)
        defaults.set(-1, forKey: "pitchDirection")  // PitchDirection.downward

        let result = defaultsManager.loadState(allPitches: allPitches)

        #expect(result.tonicPitch == tonalContext.pitch(for: 64))  // Expect saved tonic pitch
        #expect(result.pitchDirection == .downward)  // Expect saved pitch direction
    }

    @Test func testSaveState() async throws {
        // Create a test tonicPitch and pitchDirection
        let testPitch = tonalContext.pitch(for: 65)  // Example: MIDI note 65
        let testDirection: PitchDirection = .downward
        let testmode: Mode = .ionian

        // Save the state
        defaultsManager.saveState(tonicPitch: testPitch, mode: testmode, pitchDirection: testDirection)

        // Verify that the saved values match
        let savedTonicMIDI = defaults.integer(forKey: "tonicMIDI")
        let savedPitchDirection = defaults.integer(forKey: "pitchDirection")
        let savedmode = defaults.integer(forKey: "mode")

        #expect(savedTonicMIDI == 65)  // Saved tonicMIDI should be 65
        #expect(savedPitchDirection == 0)  // Saved pitchDirection should be downward (-1)
        #expect(savedmode == 0)  // Saved pitchDirection should be downward (-1)
    }
}
