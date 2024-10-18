import MIDIKitCore
import Foundation
import Combine

@MainActor
class TonalContextDefaultsManager {
    private let defaults = UserDefaults.standard

    // Load saved state from UserDefaults or return default values
    func loadState(allPitches: [Pitch]) -> (tonicPitch: Pitch, pitchDirection: PitchDirection) {
        // Load tonic pitch from UserDefaults or default to Pitch.defaultMIDI
        let tonicMIDI = defaults.integer(forKey: "tonicMIDI") == 0 ? Pitch.defaultTonicMIDI : MIDINoteNumber(defaults.integer(forKey: "tonicMIDI"))
        let tonicPitch = allPitches[Int(tonicMIDI)]

        // Load pitch direction from UserDefaults or set to .downward if -1, otherwise default to .upward
        let pitchDirectionRawValue = defaults.integer(forKey: "pitchDirection")

        // If the raw value is -1, set pitchDirection to .downward; otherwise default to .upward
        let pitchDirection: PitchDirection = pitchDirectionRawValue == -1 ? .downward : .upward

        return (tonicPitch, pitchDirection)
    }
    
    // Save the state to UserDefaults
    func saveState(tonicPitch: Pitch, pitchDirection: PitchDirection) {
        defaults.set(Int(tonicPitch.midiNote.number), forKey: "tonicMIDI")
        defaults.set(pitchDirection.rawValue, forKey: "pitchDirection")
    }

    // Bind to changes in the TonalContext and save state accordingly
    func bindAndSave(tonalContext: TonalContext) {
        // Observe changes to tonicPitch
        tonalContext.$tonicPitch
            .sink { [weak self] newValue in
                self?.saveState(tonicPitch: newValue,
                                pitchDirection: tonalContext.pitchDirection)
            }
            .store(in: &cancellables)
        
        // Observe changes to pitchDirection
        tonalContext.$pitchDirection
            .sink { [weak self] newValue in
                self?.saveState(tonicPitch: tonalContext.tonicPitch,
                                pitchDirection: newValue)
            }
            .store(in: &cancellables)
        
    }

    private var cancellables = Set<AnyCancellable>()
}
