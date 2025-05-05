import Foundation
import MIDIKitCore

public protocol MusicalInstrument: Instrument, AnyObject, Observable {

    var synthConductor:   SynthConductor? { get set }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber])
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func deactivateAllMIDINoteNumbers()
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    
    var midiInChannelRawValue: UInt4 { get set }
    var midiInChannel: MIDIChannel { get set }
    
    var midiOutChannelRawValue: UInt4 { get set }
    var midiOutChannel: MIDIChannel { get set }
    
    var latching: Bool { get set }
}

public extension MusicalInstrument {
    
    static var defaultPitchLabelTypes:    Set<PitchLabelType>    { [ .octave ] }
    static var defaultIntervalLabelTypes: Set<IntervalLabelType> { [ .symbol ] }
    
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber]) {
        deactivateAllMIDINoteNumbers()
        for midiNoteNumber in midiNoteNumbers {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        }
    }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
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
        let pitch = pitch(for: midiNoteNumber)
        synthConductor?.noteOff(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOff(pitch: pitch, midiOutChannel: ch)
        }
        pitch.deactivate()
    }
    
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber) {
        let pitch = pitch(for: midiNoteNumber)
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
    
}
