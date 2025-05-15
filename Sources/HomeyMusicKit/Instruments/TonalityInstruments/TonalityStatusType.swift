import SwiftUI
import MIDIKitCore

public enum TonalityStatusType: Int, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case tonic
    
    public var id: Self { self }

    public var label: String {
        switch self {
        case .tonic:  return "tonic status"
        }
    }

    public var icon: String {
        switch self {
        case .tonic:  return "custom.house.bubble.left"
        }
    }

    public var filledIcon: String {
        switch self {
        case .tonic:  
            return "custom.house.bubble.left.fill"
        }
    }
    
    public var isCustomIcon: Bool {
        true
    }
    
}
