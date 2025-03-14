import MIDIKitCore
import Foundation
import Combine

class TonalContextDefaultsManager {
    private let defaults = UserDefaults.standard
    
    // Load saved state from UserDefaults or return default values
    func loadState(allPitches: [Pitch]) -> (tonicPitch: Pitch, mode: Mode, pitchDirection: PitchDirection, accidental: Accidental) {
        // Load tonic pitch from UserDefaults or default to Pitch.defaultMIDI
        let tonicMIDI = defaults.integer(forKey: "tonicMIDI") == 0 ? Pitch.defaultTonicMIDINoteNumber : MIDINoteNumber(defaults.integer(forKey: "tonicMIDI"))
        let tonicPitch = allPitches[Int(tonicMIDI)]
        
        let modeRawValue = defaults.integer(forKey: "mode")
        let mode = Mode(rawValue: modeRawValue) ?? .default
        
        // Load pitch direction from UserDefaults or set to .downward if -1, otherwise default to .upward
        let pitchDirectionRawValue = defaults.integer(forKey: "pitchDirection")
        // If the raw value is -1, set pitchDirection to .downward; otherwise default to .upward
        let pitchDirection: PitchDirection = pitchDirectionRawValue == -1 ? .downward : .upward
        
        // Accidental
        let defaultAccidental: Accidental = .default
        defaults.register(defaults: [
            "accidental" : defaultAccidental.rawValue
        ])
        let accidental: Accidental = Accidental(rawValue: defaults.integer(forKey: "accidental")) ?? defaultAccidental
        
        return (tonicPitch, mode, pitchDirection, accidental)
        
    }
    
    // Save the state to UserDefaults
    func saveState(tonicPitch: Pitch, mode: Mode, pitchDirection: PitchDirection, accidental: Accidental) {
        defaults.set(Int(tonicPitch.midiNote.number), forKey: "tonicMIDI")
        defaults.set(Int(mode.rawValue), forKey: "mode")
        defaults.set(pitchDirection.rawValue, forKey: "pitchDirection")
        defaults.set(accidental.rawValue, forKey: "accidental")
    }
    
    // Bind to changes in the TonalContext and save state accordingly
    func bindAndSave(tonalContext: TonalContext) {
        // Observe changes to tonicPitch
        tonalContext.$tonicPitch
            .sink { [weak self] newValue in
                self?.saveState(
                    tonicPitch: newValue,
                    mode: tonalContext.mode,
                    pitchDirection: tonalContext.pitchDirection,
                    accidental: tonalContext.accidental
                )
            }
            .store(in: &cancellables)
        
        tonalContext.$mode
            .sink { [weak self] newValue in
                self?.saveState(
                    tonicPitch: tonalContext.tonicPitch,
                    mode: newValue,
                    pitchDirection: tonalContext.pitchDirection,
                    accidental: tonalContext.accidental
                )
            }
            .store(in: &cancellables)
        
        // Observe changes to pitchDirection
        tonalContext.$_pitchDirection
            .sink { [weak self] newValue in
                self?.saveState(
                    tonicPitch: tonalContext.tonicPitch,
                    mode: tonalContext.mode,
                    pitchDirection: newValue,
                    accidental: tonalContext.accidental
                )
            }
            .store(in: &cancellables)
        
        tonalContext.$accidental
            .sink { [weak self] newValue in
                self?.saveState(
                    tonicPitch: tonalContext.tonicPitch,
                    mode: tonalContext.mode,
                    pitchDirection: tonalContext.pitchDirection,
                    accidental: newValue
                )
            }
            .store(in: &cancellables)
        
    }
    
    private var cancellables = Set<AnyCancellable>()
}
