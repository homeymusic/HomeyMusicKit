import MIDIKitCore
import MIDIKit
import SwiftUI

public class TonalContext: ObservableObject  {
    
    public let clientName: String
    public let model: String
    public let manufacturer: String
    public let autoAdjustTonalContext: Bool
    
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
    
    @Published public var tonicPitch: Pitch {
        didSet {
            if oldValue != tonicPitch {
                buzz()
                if (autoAdjustTonalContext && oldValue.pitchClass != tonicPitch.pitchClass) {
                    mode = Mode(rawValue:  modulo(mode.rawValue + Int(tonicPitch.distance(from: oldValue)), 12))!
                }
                midiConductor.tonicPitch(pitch: tonicPitch, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    @Published public var pitchDirection: PitchDirection {
        didSet {
            if oldValue != pitchDirection {
                buzz()
                if (autoAdjustTonalContext) {
                    adjustTonicPitchForDirectionChange(from: oldValue, to: pitchDirection)
                }
                midiConductor.pitchDirection(pitchDirection: pitchDirection, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    @Published public var mode: Mode {
        didSet {
            if oldValue != mode {
                buzz()
                if autoAdjustTonalContext && mode.pitchDirection != .mixed {
                    pitchDirection = mode.pitchDirection
                }
                midiConductor.mode(mode: mode, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
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
    
    public lazy var midiConductor: MIDIConductor = {
        let conductor = MIDIConductor(tonalContext: self)
        conductor.setup()
        return conductor
    }()
    
    public init(
        clientName: String,
        model: String,
        manufacturer: String,
        autoAdjustTonalContext: Bool = false
    ) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.autoAdjustTonalContext = autoAdjustTonalContext
        
        // Now that self is fully initialized, you can load state
        let savedState = defaultsManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.mode = savedState.mode
        self.pitchDirection = savedState.pitchDirection
        
        // allPitches is initialized via its default value.
        // Set up each pitch to update activatedPitches when activated/deactivated.
        for pitch in allPitches {
            pitch.onActivate = { [weak self] activatedPitch in
                self?.activatedPitches.insert(activatedPitch)
                self?.midiConductor.noteOn(pitch: activatedPitch, midiChannel: 0)
            }
            pitch.onDeactivate = { [weak self] deactivatedPitch in
                self?.activatedPitches.remove(deactivatedPitch)
                self?.midiConductor.noteOff(pitch: deactivatedPitch, midiChannel: 0)
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
