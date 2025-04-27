import MIDIKitCore
import MIDIKit
import SwiftUI

@Observable
public final class TonalContext {
    
    // MARK: - Persistence via AppStorage
    @ObservationIgnored
    @AppStorage("tonicPitch")
    private var tonicPitchRaw: Int = Int(Pitch.defaultTonicMIDINoteNumber)
    
    @ObservationIgnored
    @AppStorage("pitchDirection")
    private var pitchDirectionRaw: Int = PitchDirection.default.rawValue
    
    @ObservationIgnored
    @AppStorage("mode")
    private var modeRaw: Int = Mode.default.rawValue
    
    @ObservationIgnored
    @AppStorage("accidental")
    private var accidentalRaw: Int = Accidental.default.rawValue
    
    // MARK: - Published Properties
    
    public var tonicPitch: Pitch = Pitch.allPitches()[Int(Pitch.defaultTonicMIDINoteNumber)] {
        didSet {
            tonicPitchRaw = Int(tonicPitch.midiNote.number)
            onTonicPitchChanged?(tonicPitch)
        }
    }
    public var onTonicPitchChanged: ((Pitch) -> Void)?
    
    public var pitchDirection: PitchDirection = .default {
        didSet {
            pitchDirectionRaw = pitchDirection.rawValue
            onPitchDirectionChanged?(pitchDirection)
        }
    }
    public var onPitchDirectionChanged: ((PitchDirection) -> Void)?
    
    public var mode: Mode = .default {
        didSet {
            modeRaw = mode.rawValue
            onModeChanged?(mode)
        }
    }
    public var onModeChanged: ((Mode) -> Void)?

    public var accidental: Accidental = Accidental.default {
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
    
    public var activatedPitches: [Pitch] {
        allPitches.filter{ $0.isActivated }
    }
    
    public var canShiftUpOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) + 12)
    }
    
    public var canShiftDownOneOctave: Bool {
        return Pitch.isValid(Int(tonicPitch.midiNote.number) - 12)
    }
    
    public func shiftUpOneOctave() {
        if canShiftUpOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number + 12)
            buzz()
        }
    }
    
    public func shiftDownOneOctave() {
        if canShiftDownOneOctave {
            tonicPitch = pitch(for: tonicPitch.midiNote.number - 12)
            buzz()
        }
    }
    
    let defaultOctave = 4
    public var octaveShift: Int {
        return tonicPitch.octave + (pitchDirection == .downward ? -1 : 0) - defaultOctave
    }
    
    public init() {
        // Initialize published properties from persisted raw values.
        self.tonicPitch = pitch(for: MIDINoteNumber(tonicPitchRaw))
        self.pitchDirection = PitchDirection(rawValue: pitchDirectionRaw) ?? PitchDirection.default
        self.mode = Mode(rawValue: modeRaw) ?? Mode.default
        self.accidental = Accidental(rawValue: accidentalRaw) ?? Accidental.default
    }
    
    // MARK: - Reset Methods & Computed Properties
    
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
            
    @MainActor
    public var pitchDirectionBinding: Binding<PitchDirection> {
        Binding(
            get: { self.pitchDirection },
            set: { newDirection in
                let oldDirection = self.pitchDirection
                if oldDirection != newDirection {
                    switch (oldDirection, newDirection) {
                    case (.mixed, .downward):
                        self.shiftUpOneOctave()
                    case (.upward, .downward):
                        self.shiftUpOneOctave()
                    case (.downward, .upward):
                        self.shiftDownOneOctave()
                    case (.downward, .mixed):
                        self.shiftDownOneOctave()
                    default:
                        break
                    }
                    buzz()
                }
                self.pitchDirection = newDirection
            }
        )
    }
}
