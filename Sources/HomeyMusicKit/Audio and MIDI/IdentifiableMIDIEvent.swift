import Foundation
import MIDIKitCore

public struct IdentifiableMIDIEvent: Identifiable, Equatable {
    public let id =         UUID()
    public let timestamp:   Date
    public let midiEvent:   MIDIEvent
    public let sourceLabel: String?
    
    public init(midiEvent: MIDIEvent, sourceLabel: String?, timestampRaw: UInt64) {
        self.midiEvent   = midiEvent
        self.sourceLabel = sourceLabel
        self.timestamp   = Date(timeIntervalSince1970: TimeInterval(timestampRaw) / 1_000_000_000)
        
    }
    
    var messageLabel: String {
        switch midiEvent {
            // Channel-Voice
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
            
            // Parameter Number
        case .rpn:              return "RPN"
        case .nrpn:             return "NRPN"
            
            // SysEx
        case .sysEx7, .sysEx8,
                .universalSysEx7,
                .universalSysEx8:
            return "SysEx"
            
            // System-Common
        case .timecodeQuarterFrame: return "Timecode Qtr-Frame"
        case .songPositionPointer:  return "Song Position"
        case .songSelect:           return "Song Select"
        case .tuneRequest:          return "Tune Request"
            
            // Real-Time
        case .timingClock:      return "Timing Clock"
        case .start:            return "Start"
        case .continue:         return "Continue"
        case .stop:             return "Stop"
        case .activeSensing:    return "Active Sensing"
        case .systemReset:      return "System Reset"
            
            // Utility (MIDI 2.0)
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
    
    public static func == (lhs: IdentifiableMIDIEvent, rhs: IdentifiableMIDIEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    var dataLabel: String {
        
        switch midiEvent {
        case let .noteOn(noteOn):
            return "Note: \(noteOn.note.number) Velocity: \(noteOn.velocity.midi1Value)"
            
        case let .noteOff(p):
            return "Note: \(p.note.number)"
            
        case let .cc(cc):
            return "\(cc.controller.description) ~ \(cc.controller.name): \(cc.value.midi1Value)"
            
        case let .sysEx7(sysEx7):
            let manufacturerName = sysEx7.manufacturer.name
            if sysEx7.manufacturer == .oneByte(0x7D) || manufacturerName == "-" {
                return "Non-Commercial or Educational Use"
            } else {
                return manufacturerName ?? sysEx7.manufacturer.description
            }
            
        default:
            return ""
        }
    }
}

extension MIDIEvent {
    var rawHex: String {
        "rawHex"
    }
}
