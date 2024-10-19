import SwiftUI
import Combine
import MIDIKitCore

@available(macOS 11.0, iOS 13.0, *)
public class Pitch: @unchecked Sendable, ObservableObject, Equatable {
    
    @Published public var isActivated: Bool = false
    // Declare the cancellables set to store subscriptions
    private var cancellables = Set<AnyCancellable>()

    public var midiNote: MIDINote

    public static let allPitches: [Pitch] = MIDINote.allNotes().map { Pitch($0) }

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

    // Computed property to get all activated pitches
    public static var activatedPitches: [Pitch] {
        return allPitches.filter { $0.isActivated }
    }

    // Static default MIDI value
    public static let defaultTonicMIDI: MIDINoteNumber = 60

    
    
//    let midiChannel = midiChannel(layoutChoice: self.layoutChoice, stringsLayoutChoice: self.stringsLayoutChoice)
    
    // move MIDI here from HomeyMusicKit?
    @MainActor
    private func setupBindings() {
        $isActivated
            .sink { [weak self] activated in
                guard let self = self else { return }
                if activated {
                    // Trigger note on when activated
                    TonalContext.shared.midiConductor?.sendNoteOn(midiNote: self.midiNote, midiChannel: 0)
                    TonalContext.shared.synthConductor.noteOn(midiNote: self.midiNote)
                } else {
                    // Trigger note off when deactivated
                    TonalContext.shared.midiConductor?.sendNoteOff(midiNote: self.midiNote, midiChannel: 0)
                    TonalContext.shared.synthConductor.noteOff(midiNote: self.midiNote)
                }
            }
            .store(in: &cancellables)
    }
    
    public func activate(midiChannel: MIDIChannel = 0) {
        self.isActivated = true
    }

    public func deactivate(midiChannel: MIDIChannel = 0)  {
        self.isActivated = false
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
    
    
    public static let naturalMIDI: [MIDINote] = MIDINote.allNotes().filter({!Pitch.accidental(midiNote: $0)})
    public static let accidentalMIDI: [MIDINote] = MIDINote.allNotes().filter({Pitch.accidental(midiNote: $0)})
    
    public var accidental: Bool {
        midiNote.isSharp
    }

    public class func accidental(midiNote: MIDINote) -> Bool {
        midiNote.isSharp
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
