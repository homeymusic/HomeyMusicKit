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
    // Allows setting pitch direction without firing callbacks
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
    
    public let allPitchClasses: [PitchClass] = (0..<12).map { PitchClass(value: $0) }
    
    public let allPitches: [Pitch]
    
    public func pitch(for midi: MIDINoteNumber) -> Pitch {
        return allPitches[Int(midi)]
    }
    
    public let allIntervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return allIntervals[distance]!
    }
    
    public var activatedPitches: [Pitch] {
        allPitches.filter { $0.isActivated }
    }
    
    // Function to check if shifting up one octave is valid
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) + 12)
    }
    
    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) - 12)
    }
    
    // Function to shift up one octave.
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number + 12)
        }
    }
    
    // Function to shift down one octave.
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
        }
    }
    
    // Computed property to determine the octave shift.
    public var octaveShift: Int {
        return tonicPitch.octave - 4
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
        self._pitchDirection = PitchDirection.default
        self.mode = Mode.default
        self.accidental = Accidental.default
        
        let pitchClasses = allPitchClasses
        self.allPitches = MIDINote.allNotes().map { note in
            let pitchClass = pitchClasses[Int(note.number) % 12]
            return Pitch(midiNote: note, pitchClass: pitchClass)
        }

        self.tonicPitch = allPitches[Int(Pitch.defaultTonicMIDINoteNumber)]

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
        self.tonicPitch.midiNote.number == Pitch.defaultTonicMIDINoteNumber
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
        let tonicNote = Int(tonicPitch.midiNote.number)
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
