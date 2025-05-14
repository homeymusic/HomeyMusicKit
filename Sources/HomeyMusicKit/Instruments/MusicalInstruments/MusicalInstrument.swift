import Foundation
import MIDIKitCore

public protocol MusicalInstrument: Instrument, AnyObject, Observable {

    var synthConductor:   SynthConductor? { get set }
    var playSynthSounds:   Bool { get set }
    
    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber, midiVelocity: MIDIVelocity)
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber], midiVelocity: MIDIVelocity)
    func deactivateMIDINoteNumber(midiNoteNumber: MIDINoteNumber)
    func deactivateAllMIDINoteNumbers()
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber, midiVelocity: MIDIVelocity)
    
    var latching: Bool { get set }
}

public extension MusicalInstrument {
    
    static var defaultPitchLabelTypes:    Set<PitchLabelType>    { [ .octave ] }
    static var defaultIntervalLabelTypes: Set<IntervalLabelType> { [ .symbol ] }
    
    func activateMIDINoteNumbers(midiNoteNumbers: [MIDINoteNumber], midiVelocity: MIDIVelocity) {
        deactivateAllMIDINoteNumbers()
        for midiNoteNumber in midiNoteNumbers {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber, midiVelocity: midiVelocity)
        }
    }

    func activateMIDINoteNumber(midiNoteNumber: MIDINoteNumber, midiVelocity: MIDIVelocity) {
        let pitch = pitch(for: midiNoteNumber)
        pitch.midiVelocity = midiVelocity
        if playSynthSounds {
            synthConductor?.noteOn(pitch: pitch)
        }
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
        pitch.midiVelocity = 0
        synthConductor?.noteOff(pitch: pitch)
        midiConductor?.dispatch(from: midiOutChannel) { instrument, ch in
            midiConductor?.noteOff(pitch: pitch, midiOutChannel: ch)
        }
        pitch.deactivate()
    }
    
    func toggleMIDINoteNumber(midiNoteNumber: MIDINoteNumber, midiVelocity: MIDIVelocity) {
        let pitch = pitch(for: midiNoteNumber)
        if pitch.isActivated {
            deactivateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
        } else {
            activateMIDINoteNumber(midiNoteNumber: midiNoteNumber, midiVelocity: midiVelocity)
        }
    }
    
}
