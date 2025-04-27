import Foundation

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
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
}

public extension Instrument {
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
}
