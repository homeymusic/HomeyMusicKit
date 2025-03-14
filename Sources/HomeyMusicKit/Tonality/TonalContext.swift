import MIDIKitCore
import MIDIKit
import SwiftUI

public class TonalContext: ObservableObject, @unchecked Sendable  {
    
    @Published public var tonicPitch: Pitch {
        didSet {
            for callback in didSetTonicPitchCallbacks {
                callback(oldValue, tonicPitch)
            }
        }
    }

    // Private backing variable that holds the published value.
    @Published public var _pitchDirection: PitchDirection = .upward

    // Public computed property for external access.
    public var pitchDirection: PitchDirection {
        get { _pitchDirection }
        set {
            let oldValue = _pitchDirection
            _pitchDirection = newValue
            notifyPitchDirectionCallbacks(from: oldValue, to: newValue)
        }
    }
    
    // Method to notify all callbacks of a change.
    private func notifyPitchDirectionCallbacks(from oldValue: PitchDirection, to newValue: PitchDirection) {
        for callback in didSetPitchDirectionCallbacks {
            callback(oldValue, newValue)
        }
    }
    
    // Update method that allows bypassing the callbacks.
    public func updatePitchDirectionWithoutCallbacks(_ newValue: PitchDirection) {
        _pitchDirection = newValue
    }

    @Published public var mode: Mode {
        didSet {
            for callback in didSetModeCallbacks {
                callback(oldValue, mode)
            }
        }
    }
    
    @Published public var accidental: Accidental
    
    private var didSetTonicPitchCallbacks: [(Pitch, Pitch) -> Void] = []
    
    public func addDidSetTonicPitchCallbacks(_ callback: @escaping (Pitch, Pitch) -> Void) {
        didSetTonicPitchCallbacks.append(callback)
    }
        
    private var didSetPitchDirectionCallbacks: [(PitchDirection, PitchDirection) -> Void] = []
    
    public func addDidSetPitchDirectionCallbacks(_ callback: @escaping (PitchDirection, PitchDirection) -> Void) {
        didSetPitchDirectionCallbacks.append(callback)
    }
            
    private var didSetModeCallbacks: [(Mode, Mode) -> Void] = []
    
    public func addDidSetModeCallbacks(_ callback: @escaping (Mode, Mode) -> Void) {
        didSetModeCallbacks.append(callback)
    }
    

    public let allPitches: [Pitch] = Pitch.allPitches()
    
    public func pitch(for midi: MIDINoteNumber) -> Pitch {
        return allPitches[Int(midi)]
    }
    
    public let allIntervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return allIntervals[distance]!
    }
    
    /// Convenience accessor for the current tonic's MIDI note number.
    public var tonicMIDINoteNumber: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
    @Published public var activatedPitches: Set<Pitch> = []
    
    // State Manager to handle saving/loading
    private let defaultsManager = TonalContextDefaultsManager()
    
    
    // Function to check if shifting up one octave is valid
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicMIDINoteNumber) + 12)
    }
    
    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicMIDINoteNumber) - 12)
    }
    
    // Function to shift up one octave.
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicMIDINoteNumber + 12)
        }
    }
    
    // Function to shift down one octave.
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicMIDINoteNumber - 12)
        }
    }
    
    // Computed property to determine the octave shift.
    public var octaveShift: Int {
        let targetMidi: MIDINoteNumber = (pitchDirection == .upward || pitchDirection == .mixed || !canShiftDownOneOctave)
        ? tonicMIDINoteNumber
        : tonicMIDINoteNumber - 12
        return pitch(for: targetMidi).octave - 4
    }
    
    private func adjustTonicPitchForDirectionChange(from oldDirection: PitchDirection, to newDirection: PitchDirection) {
        switch (oldDirection, newDirection) {
        case (.upward, .downward):
            shiftUpOneOctave()
        case (.downward, .upward):
            shiftDownOneOctave()
        default:
            break
        }
    }
    
    public init() {
        // Now that self is fully initialized, you can load state
        let savedState = defaultsManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self._pitchDirection = savedState.pitchDirection
        self.mode = savedState.mode
        self.accidental = savedState.accidental
        
        // allPitches is initialized via its default value.
        // Set up each pitch to update activatedPitches when activated/deactivated.
        for pitch in allPitches {
            
            pitch.addOnActivateCallback { activatedPitch in
                self.activatedPitches.insert(activatedPitch)
            }
            pitch.addOnDeactivateCallback { deactivatedPitch in
                self.activatedPitches.remove(deactivatedPitch)
            }
        }
        
        defaultsManager.bindAndSave(tonalContext: self)
    }
    
    public func resetToDefault() {
        resetPitchDirection()
        resetTonicPitch()
        resetMode()
    }
    
    public var isDefault: Bool {
        self.isDefaultTonicPitch && self.isDefaultPitchDirection && isDefaultMode
    }
    
    public var isDefaultTonicPitch: Bool {
        self.tonicMIDINoteNumber == Pitch.defaultTonicMIDINoteNumber
    }
    
    public var isDefaultMode: Bool {
        self.mode == Mode.default
    }
    
    public var isDefaultPitchDirection: Bool {
        self.pitchDirection == PitchDirection.default
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber) // Reset to default pitch
    }
    
    public func resetMode() {
        self.mode = .default // Reset to default mode
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }
    
    public var tonicPickerNotes: ClosedRange<Int> {
        let tonicNote = Int(tonicMIDINoteNumber)
        return pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modePickerModes: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: mode)
        return rotatedModes + [rotatedModes.first!]
    }
    
    public var tonicMIDI: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
    public func deactivateAllPitches() {
        allPitches.forEach { $0.deactivate() }
    }
    
    public var pitchDirectionBinding: Binding<PitchDirection> {
        Binding(
            get: { self.pitchDirection },
            set: { self.pitchDirection = $0 }
        )
    }
    
}
