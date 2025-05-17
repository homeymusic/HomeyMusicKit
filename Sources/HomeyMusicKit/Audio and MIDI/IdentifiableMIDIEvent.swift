import Foundation
import MIDIKitCore

public struct IdentifiableMIDIEvent: Identifiable, Equatable {
    public let id = UUID()
    public let timestamp:   Date
    public let midiEvent:   MIDIEvent
    public let sourceLabel: String?
    
    public init(
        midiEvent: MIDIEvent,
        sourceLabel: String?,
        timestamp: Date
    ) {
        self.midiEvent   = midiEvent
        self.sourceLabel = sourceLabel
        self.timestamp   = timestamp
    }
    
    private static let midiTimeFormat: Date.FormatStyle = Date.FormatStyle()
        .locale(Locale(identifier: "ga_IE"))
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .second(.twoDigits)
        .secondFraction(.fractional(3))

    public var timestampLabel: String {
        timestamp.formatted(Self.midiTimeFormat)
    }
    
    var messageLabel: String {
        switch midiEvent {
        case .noteOn:           return "Note On"
        case .noteOff:          return "Note Off"
        case .noteCC:           return "Per-Note CC"
        case .notePitchBend:    return "Per-Note Bend"
        case .notePressure:     return "Poly Aftertouch"
        case .noteManagement:   return "Per-Note Mgmt"
        case .cc:               return "CC"
        case .programChange:    return "Program Change"
        case .pitchBend:        return "Pitch Bend"
        case .pressure:         return "Aftertouch"
        case .rpn:              return "RPN"
        case .nrpn:             return "NRPN"
        case .sysEx7, .sysEx8,
            .universalSysEx7, .universalSysEx8:
            return "SysEx"
        case .timecodeQuarterFrame: return "Timecode Qtr-Frame"
        case .songPositionPointer:  return "Song Position"
        case .songSelect:           return "Song Select"
        case .tuneRequest:          return "Tune Request"
        case .timingClock:      return "Timing Clock"
        case .start:            return "Start"
        case .continue:         return "Continue"
        case .stop:             return "Stop"
        case .activeSensing:    return "Active Sensing"
        case .systemReset:      return "System Reset"
        case .noOp:             return "No-Op"
        case .jrClock:          return "JR Clock"
        case .jrTimestamp:      return "JR Timestamp"
        }
    }
    
    var channelLabel: String {
        midiEvent.channel.map { String($0.intValue + 1) } ?? ""
    }
    
    var rawHexLabel: String {
        midiEvent.midi1RawBytes()
            .map { String(format: "%02X", $0) }
            .joined(separator: " ")
    }
    
    var dataLabel: String {
        switch midiEvent {
        case let .noteOn(payload):
            return "Note: \(payload.note.number) Velocity: \(payload.velocity.midi1Value)"
        case let .noteOff(payload):
            return "Note: \(payload.note.number)"
        case let .cc(cc):
            return "\(cc.controller.description) ~ \(cc.controller.name): \(cc.value.midi1Value)"
        case let .sysEx7(sysEx7):
            let name = sysEx7.manufacturer.name
            if sysEx7.manufacturer == .oneByte(0x7D) || name == "-" {
                return "Non-Commercial or Educational Use"
            } else {
                return name ?? sysEx7.manufacturer.description
            }
        default:
            return ""
        }
    }
    
    public static func == (
        lhs: IdentifiableMIDIEvent,
        rhs: IdentifiableMIDIEvent
    ) -> Bool {
        lhs.id == rhs.id
    }
}
