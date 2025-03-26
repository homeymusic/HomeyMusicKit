import MIDIKitCore
import MIDIKit
import SwiftUI
import Combine

@MainActor
public class TonalContext: ObservableObject {
    
    // MARK: - Persistence via AppStorage
    @AppStorage("tonicPitch") private var tonicPitchRaw: Int = Int(Pitch.defaultTonicMIDINoteNumber)
    @AppStorage("pitchDirection") private var pitchDirectionRaw: Int = PitchDirection.default.rawValue
    @AppStorage("mode") private var modeRaw: Int = Mode.default.rawValue
    @AppStorage("accidental") private var accidentalRaw: Int = Accidental.default.rawValue
    
    // MARK: - Published Properties
    
    @Published public var tonicPitch: Pitch = Pitch.allPitches()[Int(Pitch.defaultTonicMIDINoteNumber)] {
        didSet {
            tonicPitchRaw = Int(tonicPitch.midiNote.number)
        }
    }
    
    // Private backing for pitchDirection.
    @Published public var pitchDirection: PitchDirection = PitchDirection.default {
        didSet {
            pitchDirectionRaw = pitchDirection.rawValue
        }
    }
    
    @Published public var mode: Mode = Mode.default {
        didSet {
            modeRaw = mode.rawValue
        }
    }
    
    @Published public var accidental: Accidental = Accidental.default {
        didSet {
            accidentalRaw = accidental.rawValue
        }
    }
    
    // MARK: - Other Properties & Methods
    
    // Store subscriptions for Combine.
    private var cancellables = Set<AnyCancellable>()

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
    
    let defaultOctave = 4
    public var octaveShift: Int {
        return tonicPitch.octave + (pitchDirection == .downward ? -1 : 0) - defaultOctave
    }
    
    // MARK: - Initialization
    private var _isInitialized = false
    public var isInitialized: Bool { _isInitialized }
    @MainActor
    public init() {
        // Initialize published properties from persisted raw values.
        self.tonicPitch = pitch(for: MIDINoteNumber(tonicPitchRaw))
        self.pitchDirection = PitchDirection(rawValue: pitchDirectionRaw) ?? PitchDirection.default
        self.mode = Mode(rawValue: modeRaw) ?? Mode.default
        self.accidental = Accidental(rawValue: accidentalRaw) ?? Accidental.default
        
        // Set up each pitch so that activation/deactivation updates activatedPitches.
        for pitch in allPitches {
            pitch.$isActivated
                .removeDuplicates()
                .sink { [weak self] isActivated in
                    guard let self = self else { return }
                    if isActivated {
                        self.activatedPitches.insert(pitch)
                    } else {
                        self.activatedPitches.remove(pitch)
                    }
                }
                .store(in: &cancellables)
        }
        _isInitialized = true
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
    
    public var pitchDirectionBinding: Binding<PitchDirection> {
        Binding(
            get: { self.pitchDirection },
            set: { newDirection in
                let oldDirection = self.pitchDirection
                if oldDirection != newDirection {
                    switch (oldDirection, newDirection) {
                    case (.upward, .downward):
                        self.shiftUpOneOctave()
                    case (.downward, .upward):
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
