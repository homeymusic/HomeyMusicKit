import SwiftUI

@MainActor
class TonalContext: ObservableObject {
    // Singleton instance
    static let shared = TonalContext()

    // Properties to drive UI changes
    public let allPitches: [Pitch] = Array(0...127).map { Pitch($0) }
    
    @Published var tonicPitch: Pitch
    @Published var pitchDirection: PitchDirection
    @Published var accidental: Accidental

    // State Manager to handle saving/loading
    private let stateManager = TonalContextStateManager()

    // Private initializer for singleton pattern
    private init() {
        // Load the initial state from the state manager
        let savedState = stateManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.pitchDirection = savedState.pitchDirection
        self.accidental = savedState.accidental
        
        // Bind and save state changes
        stateManager.bindAndSave(tonalContext: self)
    }

    // Function to reset everything to the defaults
    func resetToDefaults() {
        // Set the defaults for tonicPitch, pitchDirection, and accidental
        self.tonicPitch = allPitches[Int(Pitch.defaultMIDI)] // Reset to default pitch
        self.pitchDirection = .default // Reset to default pitch direction
        self.accidental = .default // Reset to default accidental
        
        // Save the new default state
        stateManager.saveState(tonicPitch: self.tonicPitch,
                               pitchDirection: self.pitchDirection,
                               accidental: self.accidental)
    }
}
