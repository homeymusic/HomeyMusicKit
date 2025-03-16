import MIDIKitCore
import MIDIKit
import SwiftUI

public class TonalContext: ObservableObject, @unchecked Sendable {
    
    // MARK: - Persistence via AppStorage
    @AppStorage("tonicPitch") private var tonicPitchRaw: Int = Int(Pitch.defaultTonicMIDINoteNumber)
    @AppStorage("pitchDirection") private var pitchDirectionRaw: Int = PitchDirection.default.rawValue
    @AppStorage("mode") private var modeRaw: Int = Mode.default.rawValue
    @AppStorage("accidental") private var accidentalRaw: Int = Accidental.default.rawValue
    
    // MARK: - Callbacks
    
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
    
    // MARK: - Published Properties
    
    @Published public var tonicPitch: Pitch = Pitch.allPitches()[Int(Pitch.defaultTonicMIDINoteNumber)] {
        didSet {
            tonicPitchRaw = Int(tonicPitch.midiNote.number)
            for callback in didSetTonicPitchCallbacks {
                callback(oldValue, tonicPitch)
            }
        }
    }
    
    // Private backing for pitchDirection.
    @Published public var _pitchDirection: PitchDirection = PitchDirection.default {
        didSet {
            pitchDirectionRaw = _pitchDirection.rawValue
        }
    }
    
    public var pitchDirection: PitchDirection {
        get { _pitchDirection }
        set {
            let oldValue = _pitchDirection
            _pitchDirection = newValue
            for callback in didSetPitchDirectionCallbacks {
                callback(oldValue, newValue)
            }
        }
    }
    
    @Published public var mode: Mode = Mode.default {
        didSet {
            modeRaw = mode.rawValue
            for callback in didSetModeCallbacks {
                callback(oldValue, mode)
            }
        }
    }
    
    @Published public var accidental: Accidental = Accidental.default {
        didSet {
            accidentalRaw = accidental.rawValue
        }
    }
    
    // MARK: - Other Properties & Methods
    
    public let allPitches: [Pitch] = Pitch.allPitches()
    
    public func pitch(for midi: MIDINoteNumber) -> Pitch {
        return allPitches[Int(midi)]
    }
    
    public let allIntervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return allIntervals[distance]!
    }
    
    @Published public var activatedPitches: Set<Pitch> = []
    
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) + 12)
    }
    
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) - 12)
    }
    
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number + 12)
        }
    }
    
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
        }
    }
    
    public var octaveShift: Int {
        return tonicPitch.octave - 4
    }
    
    // MARK: - Initialization
    
    public init() {
        // Initialize published properties from persisted raw values.
        self.tonicPitch = pitch(for: MIDINoteNumber(tonicPitchRaw))
        self._pitchDirection = PitchDirection(rawValue: pitchDirectionRaw) ?? PitchDirection.default
        self.mode = Mode(rawValue: modeRaw) ?? Mode.default
        self.accidental = Accidental(rawValue: accidentalRaw) ?? Accidental.default
        
        // Set up each pitch so that activation/deactivation updates activatedPitches.
        for pitch in allPitches {
            pitch.addOnActivateCallback { activatedPitch in
                self.activatedPitches.insert(activatedPitch)
            }
            pitch.addOnDeactivateCallback { deactivatedPitch in
                self.activatedPitches.remove(deactivatedPitch)
            }
        }
    }
    
    // MARK: - Reset Methods & Computed Properties
    
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
        self.tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber)
    }
    
    public func resetMode() {
        self.mode = .default
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default
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
