import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    init(tonality: Tonality)
    var tonality:  Tonality { get set }
    
    var tonicPitch: Pitch { get }
    var pitchDirection: PitchDirection { get }
    var mode: Mode { get }

    var pitches: [Pitch] { get }
    
    var intervals: [IntervalNumber: Interval] { get }
    
    var activatedPitches: [Pitch] { get }
    
    var showMIDIVelocity: Bool { get set }
    var showOutlines: Bool { get set }
    var showTonicOctaveOutlines: Bool { get set }
    var showModeOutlines: Bool { get set }
    
    var pitchLabelTypes:    Set<PitchLabelType>    { get set }
    var intervalLabelTypes: Set<IntervalLabelType> { get set }
    
    static var defaultPitchLabelTypes:    Set<PitchLabelType>    { get }
    static var defaultIntervalLabelTypes: Set<IntervalLabelType> { get }
    
    var areDefaultLabelTypes: Bool { get }
    func resetDefaultLabelTypes()
    
    var midiConductor:    MIDIConductor?     { get set }
    
    var midiInChannelRawValue: UInt4 { get set }
    var midiInChannel: MIDIChannel { get set }
    
    var midiOutChannelRawValue: UInt4 { get set }
    var midiOutChannel: MIDIChannel { get set }
    
    var midiInChannelMode: MIDIChannelMode { get set }
    var midiOutChannelMode: MIDIChannelMode { get set }
    
    var intervalColorPalette: IntervalColorPalette? { get set }
    var pitchColorPalette:    PitchColorPalette?    { get set }
    var accidental: Accidental { get set }
    var accidentalRawValue: Int { get set }
    
    @MainActor
    var colorPalette: ColorPalette { get set }
}

public extension Instrument {
    
    var _tonicPitch: Pitch {
      pitches[Int(tonality.tonicMIDINoteNumber)]
    }
    
    var tonicPitch: Pitch {
        _tonicPitch
    }
    
    var _pitchDirection: PitchDirection {
        PitchDirection(rawValue: tonality.pitchDirectionRaw) ?? .default
    }
    
    var pitchDirection: PitchDirection {
        _pitchDirection
    }
    
    var _mode: Mode {
        Mode(rawValue: tonality.modeRaw) ?? .default
    }
    
    var mode: Mode {
        _mode
    }
    
    var activatedPitches: [Pitch] {
        pitches.filter{ $0.isActivated }
    }
    
    func pitch(for midiNoteNumber: MIDINoteNumber) -> Pitch {
        pitches[Int(midiNoteNumber)]
    }
    
    func interval(fromTonicTo pitch: Pitch) -> Interval {
        let distance: IntervalNumber = Int8(pitch.distance(from: tonicPitch))
        return intervals[distance]!
    }
    
    var areDefaultLabelTypes: Bool {
        pitchLabelTypes    == Self.defaultPitchLabelTypes &&
        intervalLabelTypes == Self.defaultIntervalLabelTypes
    }
    
    func resetDefaultLabelTypes() {
        pitchLabelTypes    = Self.defaultPitchLabelTypes
        intervalLabelTypes = Self.defaultIntervalLabelTypes
    }
    
    @MainActor
    var colorPalette: ColorPalette {
        get {
            if let interval = intervalColorPalette {
                return interval
            }
            if let pitch = pitchColorPalette {
                return pitch
            }
            return IntervalColorPalette.homey
        }
        set {
            // If it's an IntervalColorPalette, store it there and clear the pitch palette
            if let interval = newValue as? IntervalColorPalette {
                intervalColorPalette = interval
                pitchColorPalette    = nil
            }
            // Otherwise if it's a PitchColorPalette, store it there and clear the interval palette
            else if let pitch = newValue as? PitchColorPalette {
                pitchColorPalette    = pitch
                intervalColorPalette = nil
            }
            // Fallback: reset to default homey interval palette
            else {
                intervalColorPalette = IntervalColorPalette.homey
                pitchColorPalette    = nil
            }
        }
    }

    var accidental: Accidental {
        get {
            Accidental(rawValue: accidentalRawValue) ?? .default
        }
        set {
            accidentalRawValue = newValue.rawValue
        }
    }
    var midiInChannel: MIDIChannel {
        get {
            MIDIChannel(rawValue: midiInChannelRawValue) ?? .default
        }
        set {
            midiInChannelRawValue = newValue.rawValue
        }
    }
    
    var midiOutChannel: MIDIChannel {
        get {
            MIDIChannel(rawValue: midiOutChannelRawValue) ?? .default
        }
        set {
            midiOutChannelRawValue = newValue.rawValue
        }
    }
    
}
