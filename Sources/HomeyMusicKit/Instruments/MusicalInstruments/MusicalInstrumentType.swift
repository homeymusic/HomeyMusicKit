import SwiftUI
import MIDIKitCore

public enum MusicalInstrumentType: Int, CaseIterable, Identifiable, Codable, Sendable {
    case tonnetz       // rawValue 0
    case linear        // 1
    case diamanti      // 2
    case piano         // 3
    case violin        // 4
    case cello         // 5
    case bass          // 6
    case banjo         // 7
    case guitar        // 8

    // MARK: - Identifiable
    public var id: Self { self }

    // MARK: - Defaults
    public static let `default`: MusicalInstrumentType = .diamanti
    public static let defaultStringMusicalInstrumentType: MusicalInstrumentType = .violin

    // MARK: - Display Label
    public var label: String {
        String(describing: self)
    }

    // MARK: - MIDI Channel
    /// Crashes if you ask for a channel on a non-MIDI picker.
    public var midiChannel: MIDIChannel {
        guard let ch = MIDIChannel(rawValue: UInt4(rawValue))
        else {
            fatalError("MusicalInstrumentType '\(self)' is not a MIDI channel")
        }
        return ch
    }

    /// 1-based string from your MIDIChannel enum
    public var midiChannelLabel: String {
        midiChannel.label
    }

    // MARK: - Icons
    public var icon: String {
        switch self {
        case .tonnetz:     return "circle.hexagongrid"
        case .linear:      return "rectangle.split.3x1"
        case .diamanti:    return "diamond"
        case .piano:       return "pianokeys"
        case .violin:      return "guitars"
        case .cello:       return "guitars"
        case .bass:        return "guitars"
        case .banjo:       return "guitars"
        case .guitar:      return "guitars"
        }
    }

    public var filledIcon: String {
        icon
    }
}

public extension MusicalInstrumentType {
    static var allInstruments: [MusicalInstrumentType] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [MusicalInstrumentType] {
        [.tonnetz, .linear, .diamanti, .piano]
    }

    static var stringInstruments: [MusicalInstrumentType] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }

    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }

    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
}
