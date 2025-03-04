import SwiftUI
import MIDIKitCore

public typealias IntervalNumber = Int8

@available(macOS 11.0, iOS 13.0, *)
public struct Interval: Sendable {
    public let distance: IntervalNumber

    // Make the initializer internal so that intervals are only created via the dictionary.
    internal init(_ distance: IntervalNumber) {
        self.distance = distance
    }

    // A static, precomputed dictionary of all intervals for values -127 ... 127.
    public static func allIntervals() -> [IntervalNumber: Interval] {
        Dictionary(uniqueKeysWithValues: (-127...127).map { ($0, Interval($0)) } )
    }

    public var intervalClass: IntervalClass {
        IntervalClass(distance: Int(distance))
    }
    
    public var wavelengthRatio: String {
        "λ " + String(decimalToFraction(1 / f_ratio))
    }

    public var wavenumberRatio: String {
        "k " + String(decimalToFraction(f_ratio))
    }

    public var periodRatio: String {
        "T " + String(decimalToFraction(1 / f_ratio))
    }

    public var frequencyRatio: String {
        "f " + String(decimalToFraction(f_ratio))
    }
    
    public var f_ratio: Double {
        MIDINote.calculateFrequency(midiNote: Int(distance)) /
        MIDINote.calculateFrequency(midiNote: 0)
    }
    
    // Forward properties to the IntervalClass.
    public var isTonic: Bool { intervalClass.isTonic }
    public var isTritone: Bool { intervalClass.isTritone }
    public var isOctave: Bool { intervalClass.isOctave }
    public var majorMinor: MajorMinor { intervalClass.majorMinor }
    public static func majorMinor(forDistance distance: Int) -> MajorMinor {
        return IntervalClass.majorMinor(distance)
    }
    public var consonanceDissonance: ConsonanceDissonance { intervalClass.consonanceDissonance }
    public var emoji: Image { intervalClass.emoji }
    public var movableDo: String { intervalClass.movableDo }

    // Forward methods that require a PitchDirection.
    public func degree(pitchDirection: PitchDirection) -> String {
        intervalClass.degree(for: pitchDirection)
    }
    public func roman(pitchDirection: PitchDirection) -> String {
        intervalClass.roman(for: pitchDirection)
    }
    public func shorthand(pitchDirection: PitchDirection) -> String {
        intervalClass.shorthand(for: pitchDirection)
    }
    public func label(pitchDirection: PitchDirection) -> String {
        intervalClass.label(for: pitchDirection)
    }
}
