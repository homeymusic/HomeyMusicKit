import MIDIKitCore
import MIDIKit
import SwiftUI

public class TonalContext: ObservableObject  {
    
    public let clientName: String
    public let model: String
    public let manufacturer: String

    /// All available pitches (created once, for example, during initialization)
    public let allPitches: [Pitch] = Pitch.allPitches()
    
    public func pitch(for midi: MIDINoteNumber) -> Pitch {
        return allPitches[Int(midi)]
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
                if (oldValue.pitchClass != tonicPitch.pitchClass) {
                    modeOffset = Mode(rawValue:  modulo(modeOffset.rawValue + Int(tonicPitch.distance(from: oldValue)), 12))!
                }
                midiConductor.tonicPitch(pitch: tonicPitch, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    @Published public var pitchDirection: PitchDirection {
        didSet {
            if oldValue != pitchDirection {
                buzz()
                adjustTonicPitchForDirectionChange(from: oldValue, to: pitchDirection)
                midiConductor.pitchDirection(pitchDirection: pitchDirection, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    @Published public var modeOffset: Mode {
        didSet {
            if oldValue != modeOffset {
                buzz()
                if modeOffset.pitchDirection != .mixed {
                    pitchDirection = modeOffset.pitchDirection
                }
                midiConductor.modeOffset(modeOffset: modeOffset, midiChannel: LayoutChoice.tonic.midiChannel())
            }
        }
    }
    
    public var mode: Mode {
        return Mode(rawValue: modulo(modeOffset.rawValue + tonicPitch.pitchClass.rawValue, 12))!
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
        manufacturer: String
    ) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        
        // Now that self is fully initialized, you can load state
        let savedState = defaultsManager.loadState(allPitches: allPitches)
        self.tonicPitch = savedState.tonicPitch
        self.modeOffset = savedState.modeOffset
        self.pitchDirection = savedState.pitchDirection
        
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
        self.modeOffset == Mode.default
    }
    
    public var isDefaultPitchDirection: Bool {
        self.pitchDirection == PitchDirection.default
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = pitch(for: Pitch.defaultTonicMIDINoteNumber) // Reset to default pitch
    }
    
    public func resetMode() {
        self.modeOffset = .default // Reset to default mode
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }
    
    public var tonicPickerNotes: ClosedRange<Int> {
        let tonicNote = Int(tonicMIDINoteNumber)
        return pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modePickerModes: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: modeOffset)
        return rotatedModes + [rotatedModes.first!]
    }
    
    public var tonicMIDI: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
    public func deactivateAllPitches() {
        allPitches.forEach { $0.deactivate() }
    }
    
}
