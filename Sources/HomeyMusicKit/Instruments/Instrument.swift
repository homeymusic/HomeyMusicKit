import Foundation

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
    var tonicPitch: Pitch { get set }
    var tonicPitchMIDINoteNumber: MIDINoteNumber { get set }
    
    /// “Latch” mode on/off
    var latching: Bool { get set }

    var showOutlines: Bool { get set }

    /// Now sets instead of arrays
    var pitchLabelChoices:    Set<PitchLabelChoice>    { get set }
    var intervalLabelChoices: Set<IntervalLabelChoice> { get set }
    
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { get }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { get }

    var areDefaultLabelChoices: Bool { get }
    func resetDefaultLabelChoices()
    
    var intervalColorPalette: IntervalColorPalette? { get set }
    var pitchColorPalette:    PitchColorPalette?    { get set }
    
    @MainActor
    var colorPalette: ColorPalette { get }
}

public extension Instrument {
    var tonicPitch: Pitch {
        get {
            Pitch.allPitches()[Int(tonicPitchMIDINoteNumber)]
        }
        set {
            // Store the new pitch’s MIDI-note number directly
            tonicPitchMIDINoteNumber = newValue.midiNote.number
        }
    }
    // the defaults as sets
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { [ .octave ] }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { [ .symbol ] }

    var areDefaultLabelChoices: Bool {
        pitchLabelChoices    == Self.defaultPitchLabelChoices &&
        intervalLabelChoices == Self.defaultIntervalLabelChoices
    }
    
    func resetDefaultLabelChoices() {
        pitchLabelChoices    = Self.defaultPitchLabelChoices
        intervalLabelChoices = Self.defaultIntervalLabelChoices
    }
    
    @MainActor
    var colorPalette: ColorPalette {
        if let interval = intervalColorPalette {
            return interval
        }
        if let pitch = pitchColorPalette {
            return pitch
        }
        return IntervalColorPalette.homey
    }
}
