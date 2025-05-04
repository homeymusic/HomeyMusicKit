import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    init(tonality: Tonality)
    var tonality:         Tonality     { get set }
    
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
    
    @MainActor
    var colorPalette: ColorPalette { get set }
}

public extension Instrument {
    
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
    
}
