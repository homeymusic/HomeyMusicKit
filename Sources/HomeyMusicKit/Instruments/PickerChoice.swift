import SwiftUI
import MIDIKitIO

public enum PickerChoice: Int, CaseIterable, Identifiable, Codable, Sendable {
    case tonicPicker
    case modePicker
    
    public var id: Self { self }
    
    public var label: String {
        switch self {
        case .tonicPicker: return "tonic picker"
        case .modePicker: return "mode picker"
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
        }
    }

}
