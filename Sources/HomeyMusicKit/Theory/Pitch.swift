import SwiftUI
import Combine
import MIDIKitCore

@available(macOS 11.0, iOS 13.0, *)
public class Pitch: @unchecked Sendable, ObservableObject, Equatable {
        
    public var isActivated = false
    
    // Declare the cancellables set to store subscriptions
    
    private var cancellables = Set<AnyCancellable>()

    public var midiNote: MIDINote

    public static let allPitches: [Pitch] = MIDINote.allNotes().map { Pitch($0) }

    public static func isValidPitch(_ anyInt: Int) -> Bool {
        return 0 <= anyInt && anyInt <= 127
    }
    
    public static func pitch(for midi: MIDINoteNumber) -> Pitch {
        return Pitch.allPitches[Int(midi)]
    }
       
    private init(_ midiNote: MIDINote) {
        self.midiNote = midiNote
    }

    public func interval(from: Pitch) -> Interval {
        return Interval.interval(from: from, to: self)
    }

    public func distance(from: Pitch) -> IntervalNumber {
        return IntervalNumber(self.midiNote.number) - IntervalNumber(from.midiNote.number)
    }

    // Static default MIDI value
    public static let defaultTonicMIDI: MIDINoteNumber = 60
    
    @MainActor
    public func activate() {
        TonalContext.shared.synthConductor.noteOn(pitch: self)
        TonalContext.shared.midiConductor.noteOn(pitch: self, midiChannel: 0)
        TonalContext.shared.activatedPitches.insert(self)
        isActivated = true
    }

    @MainActor
    public func deactivate() {
        TonalContext.shared.synthConductor.noteOff(pitch: self)
        TonalContext.shared.midiConductor.noteOff(pitch: self, midiChannel: 0)
        TonalContext.shared.activatedPitches.remove(self)
        isActivated = false
    }
    
    @MainActor
    public static func deactivateAllPitches() {
        for pitch in allPitches {
            pitch.deactivate()
        }
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
    
    public static let speedOfSound: Double = MIDINote.calculateFrequency(midiNote: 65)
    
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
    
    public var isNatural: Bool {
        !midiNote.isSharp
    }

    public static func isNatural(_ anyInt: Int) -> Bool {
        return [0,2,4,5,7,9,11].contains(modulo(anyInt, 12))
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
