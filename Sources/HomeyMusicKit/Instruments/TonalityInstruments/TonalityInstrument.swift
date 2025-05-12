import SwiftData
import MIDIKitCore

@Model
public final class TonalityInstrument: Instrument {
    public init(
        tonality: Tonality = Tonality()
    ) {
        self.tonality = tonality
    }
    
    public init(
        tonality: Tonality = Tonality(),
        showModePicker: Bool = true,
        showTonicPicker: Bool = true,
        isAutoModeAndTonicEnabled: Bool = true,
        showOutlines: Bool = true,
        showTonicOctaveOutlines: Bool = true,
        showModeOutlines: Bool = true
    ) {
        self.tonality                  = tonality
        self.showModePicker            = showModePicker
        self.showTonicPicker           = showTonicPicker
        self.isAutoModeAndTonicEnabled = isAutoModeAndTonicEnabled
        self.showOutlines              = showOutlines
        self.showTonicOctaveOutlines   = showTonicOctaveOutlines
        self.showModeOutlines          = showModeOutlines
    }
    
    @Relationship
    public var tonality: Tonality
    
    @Transient
    public var pitches: [Pitch] = Pitch.allPitches()
    
    @Transient
    public var intervals: [IntervalNumber: Interval] = Interval.allIntervals()
    
    public var defaultTonicPitch: Pitch {
        pitch(for: Pitch.defaultTonicMIDINoteNumber)
    }
    
    public var tonicPitch: Pitch {
        get {
            _tonicPitch
        }
        set {
            let tonicMIDINoteNumber: MIDINoteNumber = newValue.midiNote.number
            tonality.tonicMIDINoteNumber = tonicMIDINoteNumber
            tonality.broadcastChange(tonicMIDINoteNumber) { midiConductor, updatedMIDINoteNumber, midiChannel in
                midiConductor.tonicMIDINoteNumber(updatedMIDINoteNumber, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var pitchDirection: PitchDirection {
        get {
            _pitchDirection
        }
        set {
            tonality.pitchDirectionRaw = newValue.rawValue
            tonality.broadcastChange(newValue.rawValue) { midiConductor, updatedPitchDirectionRaw, midiChannel in
                midiConductor.pitchDirectionRaw(updatedPitchDirectionRaw, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var mode: Mode {
        get {
            _mode
        }
        set {
            tonality.modeRaw = newValue.rawValue
            tonality.broadcastChange(newValue.rawValue) { midiConductor, updatedModeRaw, midiChannel in
                midiConductor.modeRaw(updatedModeRaw, midiOutChannel: midiChannel)
            }
        }
    }
    
    public var showTonicPicker: Bool {
        get { tonalityControlTypes.contains(.tonicPicker) }
        set {
            if newValue {
                tonalityControlTypes.insert(.tonicPicker)
            } else {
                tonalityControlTypes.remove(.tonicPicker)
            }
        }
    }

    public var showModePicker: Bool {
        get { tonalityControlTypes.contains(.modePicker) }
        set {
            if newValue {
                tonalityControlTypes.insert(.modePicker)
            } else {
                tonalityControlTypes.remove(.modePicker)
            }
        }
    }
    
    public var showPitchDirectionPicker: Bool {
        get { tonalityControlTypes.contains(.pitchDirectionPicker) }
        set {
            if newValue {
                tonalityControlTypes.insert(.pitchDirectionPicker)
            } else {
                tonalityControlTypes.remove(.pitchDirectionPicker)
            }
        }
    }
    
    public var showOctaveShifter: Bool {
        get { tonalityControlTypes.contains(.octaveShifter) }
        set {
            if newValue {
                tonalityControlTypes.insert(.octaveShifter)
            } else {
                tonalityControlTypes.remove(.octaveShifter)
            }
        }
    }
    
    public var showResetter: Bool {
        get { tonalityControlTypes.contains(.resetter) }
        set {
            if newValue {
                tonalityControlTypes.insert(.resetter)
            } else {
                tonalityControlTypes.remove(.resetter)
            }
        }
    }
    
    public var isAutoModeAndTonicEnabled: Bool = true
    
    public var showOutlines: Bool = true
    public var showTonicOctaveOutlines: Bool = true
    public var showModeOutlines: Bool = true
    
    @Relationship public var intervalColorPalette: IntervalColorPalette?
    @Relationship public var pitchColorPalette: PitchColorPalette?
    
    public var pitchLabelTypes: Set<PitchLabelType> = TonalityInstrument.defaultPitchLabelTypes
    public var intervalLabelTypes: Set<IntervalLabelType> = TonalityInstrument.defaultIntervalLabelTypes
    public var tonalityControlTypes: Set<TonalityControlType> = TonalityInstrument.defaultTonalityControlTypes

    public static var defaultPitchLabelTypes:    Set<PitchLabelType>    { [ .letter, .mode ] }
    public static var defaultIntervalLabelTypes: Set<IntervalLabelType> { [ .symbol ] }
    public static var defaultTonalityControlTypes: Set<TonalityControlType> {
        [ .tonicPicker, .modePicker, .pitchDirectionPicker, .octaveShifter, .resetter ]
    }

    public var accidentalRawValue: Int = Accidental.default.rawValue
    
    @Transient
    public var midiConductor: MIDIConductor?
    public var midiInChannelMode:  MIDIChannelMode  = MIDIChannelMode.defaultIn
    public var midiOutChannelMode: MIDIChannelMode = MIDIChannelMode.defaultOut

    public var availableMIDINoteInts: ClosedRange<Int> {
        let tonicNote = Int(tonicPitch.midiNote.number)
        return tonality.pitchDirectionRaw == PitchDirection.downward.rawValue ? tonicNote - 12 ... tonicNote : tonicNote ... tonicNote + 12
    }
    
    public var availableModes: [Mode] {
        let rotatedModes = Mode.rotatedCases(startingWith: mode)
        return rotatedModes + [rotatedModes.first!]
    }
        
    public func shiftUpOneOctave() {
        if tonality.canShiftUpOneOctave {
            tonicPitch = pitch(for: tonality.tonicMIDINoteNumber + 12)
        }
    }
    
    public func shiftDownOneOctave() {
        if tonality.canShiftDownOneOctave {
            tonicPitch = pitch(for: tonality.tonicMIDINoteNumber - 12)
        }
    }
    
    public func resetTonality() {
        tonicPitch = defaultTonicPitch
        mode = Mode.default
        pitchDirection = PitchDirection.default
        tonality.areModeAndTonicLinked = Tonality.modeAndTonicLinkDefault
    }
    
    public static let horizontalCellCount = 13.0
    
    public var areModeAndTonicPickersShown: Bool {
        showModePicker &&
        showTonicPicker
    }
    
    public var isModeOrTonicPickersShown: Bool {
        showModePicker ||
        showTonicPicker
    }
    
    public var areBothModeLabelsShown: Bool {
        pitchLabelTypes.contains(.mode) &&
        pitchLabelTypes.contains(.map)
    }
    
    public var viewRatio : Double {
        if areModeAndTonicPickersShown {
            return TonalityInstrument.horizontalCellCount / (areBothModeLabelsShown ? 2.0 : 1.5)
        } else if showModePicker {
            return TonalityInstrument.horizontalCellCount  * modePickerAspectMultiplier
        } else {
            return TonalityInstrument.horizontalCellCount
        }
    }
    
    public var modePickerAspectMultiplier: Double {
        if areBothModeLabelsShown {
            return 1.0
        } else {
            return 2.0
        }
    }


}
