import SwiftUI
import MIDIKitCore

public enum TonalityStatusType: Int, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case tonic
    case midiMonitor
    
    public var id: Self { self }

    public var label: String {
        switch self {
        case .tonic:  return "tonic status"
        case .midiMonitor: return "midi monitor"
        }
    }

    public var icon: String {
        switch self {
        case .tonic:  return "custom.house.bubble.left"
        case .midiMonitor: return "list.bullet.rectangle"
        }
    }

    public var filledIcon: String {
        switch self {
        case .tonic: return "custom.house.bubble.left.fill"
        case .midiMonitor: return "list.bullet.rectangle.fill"
        }
    }
    
    public var isCustomIcon: Bool {
        switch self {
        case .tonic: return true
        case .midiMonitor: return false
        }
    }
    
}
