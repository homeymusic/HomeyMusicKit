import SwiftUI
import MIDIKitCore
public typealias IntervalNumber = Int8

@available(macOS 11.0, iOS 13.0, *)
public class Interval: ObservableObject {
    
    @Published public var tonicPitch: Pitch?
    @Published public var pitch: Pitch?

    public let distance: IntervalNumber

    private init(_ distance: IntervalNumber) {
        self.distance = distance
    }

    public static let allIntervals: [IntervalNumber: Interval] =
    Dictionary(
        uniqueKeysWithValues: (-127...127).map { ($0, Interval($0)) }
    )

    public static func interval(from tonicPitch: Pitch, to pitch: Pitch) -> Interval {
        let distance: IntervalNumber = pitch.distance(from: tonicPitch)
        
        // Directly retrieve the interval without optional handling, assuming a valid distance range
        let interval = allIntervals[distance]!
        interval.tonicPitch = tonicPitch
        interval.pitch = pitch

        return interval
    }
    
    public var intervalClass: IntervalClass {
        IntervalClass(distance: Int(distance))
    }
    
    public var wavelengthRatio: String {
        "λ " + String(decimalToFraction(1/f_ratio))
    }

    public var wavenumberRatio: String {
        "ṽ " + String(decimalToFraction(f_ratio))
    }

    public var periodRatio: String {
        "T " + String(decimalToFraction(1/f_ratio))
    }

    public var frequencyRatio: String {
        "f " + String(decimalToFraction(f_ratio))
    }
    
    public var f_ratio: Double {
        MIDINote.calculateFrequency(midiNote: Int(distance)) / MIDINote.calculateFrequency(midiNote: 0)
    }
    
    // Manually forward properties to IntervalClass

    public var isTonic: Bool {
        return intervalClass.isTonic
    }

    public var isTritone: Bool {
        return intervalClass.isTritone
    }

    public var isOctave: Bool {
        return intervalClass.isOctave
    }

    public var majorMinor: MajorMinor {
        return intervalClass.majorMinor
    }

    public static func majorMinor(_ distance: Int) -> MajorMinor {
        return IntervalClass.majorMinor(distance)
    }

    public var consonanceDissonance: ConsonanceDissonance {
        return intervalClass.consonanceDissonance
    }

    public var emoji: Image {
        return intervalClass.emoji
    }

    public var movableDo: String {
        return intervalClass.movableDo
    }

    // Manually forward methods that require PitchDirection to IntervalClass
    
    public func degree(pitchDirection: PitchDirection) -> String {
        return intervalClass.degree(for: pitchDirection)
    }

    public func roman(pitchDirection: PitchDirection) -> String {
        return intervalClass.roman(for: pitchDirection)
    }

    public func shorthand(pitchDirection: PitchDirection) -> String {
        return intervalClass.shorthand(for: pitchDirection)
    }

    public func label(pitchDirection: PitchDirection) -> String {
        return intervalClass.label(for: pitchDirection)
    }

}
