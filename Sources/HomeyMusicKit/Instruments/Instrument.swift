import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    init(tonality: Tonality)
    var tonality:  Tonality { get set }
    
    var tonicPitch: Pitch { get }
    
    var pitches: [Pitch] { get }
    
    var intervals: [IntervalNumber: Interval] { get }
    
    var activatedPitches: [Pitch] { get }
    
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
    var allMIDIInChannels: Bool { get set }
    var allMIDIOutChannels: Bool { get set }
    
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
    
    public var activatedPitches: [Pitch] {
        pitches.filter{ $0.isActivated }
    }
    
    public func pitch(for midiNoteNumber: MIDINoteNumber) -> Pitch {
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
}
