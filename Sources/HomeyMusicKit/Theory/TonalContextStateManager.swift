import Foundation
import Combine

@MainActor
class TonalContextStateManager {
    private let defaults = UserDefaults.standard

    // Load saved state from UserDefaults or return default values
    func loadState(allPitches: [Pitch]) -> (tonicPitch: Pitch, pitchDirection: PitchDirection, accidental: Accidental) {
        // Load tonic pitch from UserDefaults or default to Pitch.defaultMIDI
        let tonicMIDI = defaults.integer(forKey: "tonicMIDI") == 0 ? Pitch.defaultMIDI : Int8(defaults.integer(forKey: "tonicMIDI"))
        let tonicPitch = allPitches[Int(tonicMIDI)]

        // Load pitch direction from UserDefaults or default to .upward
        let pitchDirectionRawValue = defaults.integer(forKey: "pitchDirection")
        let pitchDirection = PitchDirection(rawValue: pitchDirectionRawValue) ?? .upward

        // Load accidental from UserDefaults or default to .sharp
        let accidentalRawValue = defaults.integer(forKey: "accidental")
        let accidental = Accidental(rawValue: accidentalRawValue) ?? .sharp

        return (tonicPitch, pitchDirection, accidental)
    }

    // Save the state to UserDefaults
    func saveState(tonicPitch: Pitch, pitchDirection: PitchDirection, accidental: Accidental) {
        defaults.set(Int(tonicPitch.midi), forKey: "tonicMIDI")
        defaults.set(pitchDirection.rawValue, forKey: "pitchDirection")
        defaults.set(accidental.rawValue, forKey: "accidental")
    }

    // Bind to changes in the TonalContext and save state accordingly
    func bindAndSave(tonalContext: TonalContext) {
        // Observe changes to tonicPitch
        tonalContext.$tonicPitch
            .sink { [weak self] newValue in
                self?.saveState(tonicPitch: newValue,
                                pitchDirection: tonalContext.pitchDirection,
                                accidental: tonalContext.accidental)
            }
            .store(in: &cancellables)
        
        // Observe changes to pitchDirection
        tonalContext.$pitchDirection
            .sink { [weak self] newValue in
                self?.saveState(tonicPitch: tonalContext.tonicPitch,
                                pitchDirection: newValue,
                                accidental: tonalContext.accidental)
            }
            .store(in: &cancellables)
        
        // Observe changes to accidental
        tonalContext.$accidental
            .sink { [weak self] newValue in
                self?.saveState(tonicPitch: tonalContext.tonicPitch,
                                pitchDirection: tonalContext.pitchDirection,
                                accidental: newValue)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
}
