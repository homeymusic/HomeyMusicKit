import Foundation
import MIDIKitCore

public protocol Instrument: AnyObject, Observable {
    init(tonality: Tonality)
    
    var instrumentChoice: InstrumentChoice { get }
    
    var tonality:         Tonality     { get set }
    var synthConductor:   SynthConductor? { get set }
    var midiConductor:    MIDIConductor?     { get set }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber])
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func deactivateAllMIDINoteNumbers()
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    
    var midiInChannelRawValue: UInt4 { get set }
    var midiInChannel: MIDIChannel { get set }
    var allMIDIInChannels: Bool { get set }
    
    var midiOutChannelRawValue: UInt4 { get set }
    var midiOutChannel: MIDIChannel { get set }
    var allMIDIOutChannels: Bool { get set }
    
    var latching: Bool { get set }
    
    var showOutlines: Bool { get set }
    var showTonicOctaveOutlines: Bool { get set }
    var showModeOutlines: Bool { get set }
    
    var pitchLabelChoices:    Set<PitchLabelChoice>    { get set }
    var intervalLabelChoices: Set<IntervalLabelChoice> { get set }
    
    static var defaultPitchLabelChoices:    Set<PitchLabelChoice>    { get }
    static var defaultIntervalLabelChoices: Set<IntervalLabelChoice> { get }
    
    var areDefaultLabelChoices: Bool { get }
    func resetDefaultLabelChoices()
    
    var intervalColorPalette: IntervalColorPalette? { get set }
    var pitchColorPalette:    PitchColorPalette?    { get set }
    
    @MainActor
    var colorPalette: ColorPalette { get set }
}

public extension Instrument {
    
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber]) {
        deactivateAllMIDINoteNumbers()
        for midiNoteNumber in midiNoteNumbers {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        }
    }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = tonality.pitch(for: midiNoteNumber)
        synthConductor?.noteOn(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOn(pitch: pitch, midiOutChannel: ch)
        }
        pitch.activate()
    }
    
    func deactivateAllMIDINoteNumbers() {
        MIDINote.allNotes().forEach { midiNote in
            deactivateMIDINoteNumber(midiNoteNumber: midiNote.number)
        }
    }
    
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = tonality.pitch(for: midiNoteNumber)
        synthConductor?.noteOff(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOff(pitch: pitch, midiOutChannel: ch)
        }
        pitch.deactivate()
    }
    
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = tonality.pitch(for: midiNoteNumber)
        if pitch.isActivated {
            deactivateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        } else {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
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
