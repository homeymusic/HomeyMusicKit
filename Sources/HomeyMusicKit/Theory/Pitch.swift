import SwiftUI
import MIDIKitCore

@available(macOS 11.0, iOS 13.0, *)
public class Pitch: @unchecked Sendable, ObservableObject, Equatable {
    
    public var midiNote: MIDINote

    private init(_ midiNote: MIDINote) {
        self.midiNote = midiNote
    }

    // Properties to drive UI changes
    public static let allPitches: [Pitch] = MIDINote.allNotes().map { Pitch($0) }

    public static func pitch(for midi: MIDINoteNumber) -> Pitch {
        return Pitch.allPitches[Int(midi)]
    }
    
    // Static default MIDI value
    public static let defaultTonicMIDI: MIDINoteNumber = 60

    // Boolean property to track activation state
    @Published public var activated: Bool = false
    
    // Helper function to activate the pitch
//            let midiChannel = midiChannel(layoutChoice: layoutChoice, stringsLayoutChoice: stringsLayoutChoice)
//    func activatePitch(pitch: Pitch, midiChannel: UInt4) {
//        midiConductor?.sendNoteOn(noteNumber: MIDINoteNumber(pitch.midi), midiChannel: midiChannel)
//        pitch.noteOn()
//        synthConductor.noteOn(pitch: pitch)
//    }
    
//    let midiChannel = midiChannel(layoutChoice: self.layoutChoice, stringsLayoutChoice: self.stringsLayoutChoice)

    public func activate() {
        self.activated = true
        // Add additional logic if necessary (e.g., send MIDI on message)
    }
//
//    func deactivatePitch(pitch: Pitch, midiChannel: UInt4) {
//        midiConductor?.sendNoteOff(noteNumber: MIDINoteNumber(pitch.intValue), midiChannel: midiChannel)
//        pitch.noteOff()
//        synthConductor.noteOff(pitch: pitch)
//    }
//

    // Helper function to deactivate the pitch
    public func deactivate() {
        self.activated = false
        // Add additional logic if necessary (e.g., send MIDI off message)
    }

    // Computed property to dynamically get the interval from the tonic
    @MainActor public var interval: Interval {
        let tonicPitch = TonalContext.shared.tonicPitch
        let semitoneDifference: IntervalNumber = IntervalNumber(midiNote.number) - IntervalNumber(tonicPitch.midiNote.number)
        return Interval.interval(for: semitoneDifference)
    }

    public var pitchClass: PitchClass {
        PitchClass(noteNumber: Int(midiNote.number))
    }
    
    public var fundamentalFrequency: Double {
        midiNote.frequencyValue()
    }
    
    public var fundamentalPeriod: Double {
        1 / fundamentalFrequency
    }
    
    public static let speedOfSound: Double = 343.0
    public var wavelength: Double {
        return Pitch.speedOfSound * fundamentalPeriod
    }
    
    public var wavenumber: Double {
        return 1 / wavelength
    }

    // Cochlea returns the Greenwood function for position on the basilar membrane.
    // Position within the cochlea is a spatial characteristic, not a temporal one.
    // Yet, the original Greenwood funtion measures position relative to the apex.
    // Orientation from the apex has position increase as wavelength decreases.
    // That situation gives us a confusing decreasing spatial relationship.
    // Instead we choose to orient the position from the base of the cochlea
    // so that position on the basilar membrane increases with increasing wavelength.
    // This situation gives us an intuitive spatial relationship where position on
    // the basilar membrane increases with inreasing wavelength.
    public var cochlea: Double {
        return 100 - 100 * (log10( fundamentalFrequency / 165.4 + 0.88 ) / 2.1)
    }
    
    public var accidental: Bool {
        midiNote.isSharp
    }
    
    public static let naturalMIDI: [MIDINoteNumber] = Array(0...127).filter({!Pitch.accidental(note: Int($0))})
    public static let accidentalMIDI: [MIDINoteNumber] = Array(0...127).filter({Pitch.accidental(note: Int($0))})
    
    public class func accidental(note: Int) -> Bool {
        switch PitchClass(noteNumber: note) {
        case .one, .three, .six, .eight, .ten:
            return true
        case .zero, .two, .four, .five, .seven, .nine, .eleven:
            return false
        }
    }
    
    public func isOctave(relativeTo otherPitch: Pitch) -> Bool {
        let semitoneDifference = Int(self.midiNote.number) - Int(otherPitch.midiNote.number)
        return abs(semitoneDifference) == 12
    }

    public var octave: Int {
        Int(self.midiNote.number / 12) - 1
    }

    public var intValue: Int {
        Int(self.midiNote.number)
    }
    
    public static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        lhs.midiNote.number < rhs.midiNote.number
    }
            
    public static func == (lhs: Pitch, rhs: Pitch) -> Bool {
        lhs.midiNote.number == rhs.midiNote.number
    }
    
    public func letter(_ accidental: Accidental) -> String {
        switch pitchClass {
        case .zero:
            "C"
        case .one:
            accidental == .sharp ? "C♯" : "D♭"
        case .two:
            "D"
        case .three:
            accidental == .sharp ? "D♯" : "E♭"
        case .four:
            "E"
        case .five:
            "F"
        case .six:
            accidental == .sharp ? "F♯" : "G♭"
        case .seven:
            "G"
        case .eight:
            accidental == .sharp ? "G♯" : "A♭"
        case .nine:
            "A"
        case .ten:
            accidental == .sharp ? "A♯" : "B♭"
        case .eleven:
            "B"
        }
    }
    
    public func fixedDo(_ accidental: Accidental) -> String {
        switch pitchClass {
        case .zero:
            "Do"
        case .one:
            accidental == .sharp ? "Do♯" : "Re♭"
        case .two:
            "Re"
        case .three:
            accidental == .sharp ? "Re♯" : "Mi♭"
        case .four:
            "Mi"
        case .five:
            "Fa"
        case .six:
            accidental == .sharp ? "Fa♯" : "Sol♭"
        case .seven:
            "Sol"
        case .eight:
            accidental == .sharp ? "Sol♯" : "La♭"
        case .nine:
            "La"
        case .ten:
            accidental == .sharp ? "La♯" : "Si♭"
        case .eleven:
            "Si"
        }
    }

    public var mode: Mode {
        Mode(rawValue: Int(self.pitchClass.rawValue))!
    }

    // Function to check if shifting up one octave is valid
    public var canShiftUpOneOctave: Bool {
        return MIDINoteNumber(exactly: midiNote.number + 12) != nil
    }

    // Function to check if shifting down one octave is valid
    public var canShiftDownOneOctave: Bool {
        return MIDINoteNumber(exactly: midiNote.number - 12) != nil
    }

    // Function to shift up one octave, returning the pitch from allPitches
    public func upAnOctave() -> Pitch {
        if let newMIDIValue = MIDINoteNumber(exactly: midiNote.number + 12) {
            return Pitch.pitch(for: newMIDIValue)  // Return the Pitch from allPitches
        } else {
            return self  // If invalid, return the current pitch
        }
    }

    // Function to shift down one octave, returning the pitch from allPitches
    public func downAnOctave() -> Pitch {
        if let newMIDIValue = MIDINoteNumber(exactly: midiNote.number - 12) {
            return Pitch.pitch(for: newMIDIValue)  // Return the Pitch from allPitches
        } else {
            return self  // If invalid, return the current pitch
        }
    }

}

@available(macOS 11.0, iOS 13.0, *)
extension Pitch: Identifiable, Hashable, Comparable  {
    public var id: MIDINoteNumber {
        return self.midiNote.number
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
}
