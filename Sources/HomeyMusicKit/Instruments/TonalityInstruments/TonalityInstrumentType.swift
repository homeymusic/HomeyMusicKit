import SwiftUI
import MIDIKitCore

public enum TonalityMusicalInstrumentType: Int, CaseIterable, Identifiable, Codable, Sendable {
    case modePicker
    case tonicPicker

    public var id: Self { self }

    public var label: String {
        switch self {
        case .modePicker:  return "mode picker"
        case .tonicPicker: return "tonic picker"
        }
    }

    public var icon: String {
        switch self {
        case .modePicker:  return "location.viewfinder"
        case .tonicPicker: return "house"
        }
    }

    public var filledIcon: String {
        switch self {
        case .modePicker:  return "location.square.fill"
        case .tonicPicker: return "house.fill"
        default:           return icon
        }
    }
}
