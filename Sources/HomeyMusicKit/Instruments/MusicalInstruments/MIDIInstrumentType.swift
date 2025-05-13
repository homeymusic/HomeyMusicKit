import SwiftUI
import MIDIKitCore

public enum MIDIInstrumentType: Int, CaseIterable, Identifiable, Codable, Sendable {
    case tonnetz  = 0
    case linear
    case diamanti
    case piano
    case violin
    case cello
    case bass
    case banjo
    case guitar  
    case tonality  = 15
    
    // MARK: - Identifiable
    public var id: Self { self }

    // MARK: - Defaults
    public static let `default`: MIDIInstrumentType = .diamanti
    public static let defaultStringMusicalInstrumentType: MIDIInstrumentType = .violin

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
        case .tonality:    return "brain.filled.head.profile"
        }
    }

    public var filledIcon: String {
        icon
    }
}

public extension MIDIInstrumentType {
    static var allInstruments: [MIDIInstrumentType] {
        keyboardInstruments + stringInstruments
    }

    static var keyboardInstruments: [MIDIInstrumentType] {
        [.tonnetz, .linear, .diamanti, .piano]
    }

    static var stringInstruments: [MIDIInstrumentType] {
        [.violin, .cello, .bass, .banjo, .guitar]
    }

    var isKeyboardInstrument: Bool {
        Self.keyboardInstruments.contains(self)
    }

    var isStringInstrument: Bool {
        Self.stringInstruments.contains(self)
    }
}
