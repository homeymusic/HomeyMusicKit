import MIDIKitCore
import MIDIKit
import SwiftUI

@MainActor
public class TonalContext: ObservableObject, @unchecked Sendable  {
    // Private backing store for the singleton instance.
    private static var _shared: TonalContext?

    /// The shared singleton instance.
    /// Accessing this before configuration will cause a runtime error.
    public static var shared: TonalContext {
        guard let instance = _shared else {
            fatalError("TonalContext not configured. Call TonalContext.configure(clientName:, model:, manufacturer:) before accessing TonalContext.shared.")
        }
        return instance
    }
    
    /// Configure the singleton with the required identification.
    /// This must be called once, at app startup.
    public static func configure(
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        guard _shared == nil else {
            fatalError("TonalContext already configured.")
        }
        _shared = TonalContext(
            clientName: clientName,
            model: model,
            manufacturer: manufacturer
        )
    }
    
    // These properties hold the identification values.
    public let clientName: String
    public let model: String
    public let manufacturer: String

    @Published public var activatedPitches: Set<Pitch> = []
    
    public var midiConductor: MIDIConductor
    
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
        return Pitch.isValidPitch(Int(tonicMIDI) + 12)
    }
    
    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValidPitch(Int(tonicMIDI) - 12)
    }
    
    // Function to shift up one octave, returning the pitch from allPitches
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = Pitch.pitch(for: tonicMIDI + 12)
        }
    }
    
    // Function to shift down one octave, returning the pitch from allPitches
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = Pitch.pitch(for: tonicMIDI - 12)
        }
    }
    
    // Computed property to determine the octave shift
    public var octaveShift: Int {
        let midi = if pitchDirection == .upward || pitchDirection == .mixed || !canShiftDownOneOctave {
            self.tonicMIDI
        } else {
            self.tonicMIDI - 12
        }
        return Pitch.pitch(for: midi).octave - 4
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
    
    private init(
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        self.midiConductor = MIDIConductor(
            clientName: self.clientName,
            model: self.model,
            manufacturer: self.manufacturer
        )
        self.midiConductor.setup()
        
        // Load state and initialize tonic and pitchDirection
        let savedState = defaultsManager.loadState(allPitches: Pitch.allPitches)
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
        self.tonicPitch.midiNote.number == Pitch.defaultTonicMIDI
    }
    
    public var isDefaultMode: Bool {
        self.modeOffset == Mode.default
    }
    
    public var isDefaultPitchDirection: Bool {
        self.pitchDirection == PitchDirection.default
    }
    
    public func resetTonicPitch() {
        self.tonicPitch = Pitch.pitch(for: Pitch.defaultTonicMIDI) // Reset to default pitch
    }
    
    public func resetMode() {
        self.modeOffset = .default // Reset to default mode
    }
    
    public func resetPitchDirection() {
        self.pitchDirection = .default // Reset to default pitch direction
    }
    
    public var tonicPickerNotes: ClosedRange<Int> {
        let tonicNote = Int(tonicMIDI)
        return pitchDirection == .downward ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var modePickerModes: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: modeOffset)
        return rotatedModes + [rotatedModes.first!]
    }
    
    public var tonicMIDI: MIDINoteNumber {
        tonicPitch.midiNote.number
    }
    
}
