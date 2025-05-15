import SwiftUI
import MIDIKitCore

public enum TonalityControlType: Int, CaseIterable, Identifiable, Codable, Sendable, IconRepresentable {
    case modePicker
    case tonicPicker
    case pitchDirectionPicker
    case octaveShifter
    case resetter
    
    public var id: Self { self }

    public var label: String {
        switch self {
        case .modePicker:  return "mode picker"
        case .tonicPicker: return "tonic picker"
        case .pitchDirectionPicker: return "pitch direction picker"
        case .octaveShifter: return "octave shifter"
        case .resetter: return "resetter"
        }
    }

    public var icon: String {
        switch self {
        case .modePicker:  return "location.viewfinder"
        case .tonicPicker: return "house"
        case .pitchDirectionPicker: return "greaterthan.square"
        case .octaveShifter: return "water.waves.and.arrow.trianglehead.up"
        case .resetter: return "arrow.trianglehead.counterclockwise"
        }
    }

    public var filledIcon: String {
        switch self {
        case .modePicker:  return "location.square.fill"
        case .tonicPicker: return "house.fill"
        case .pitchDirectionPicker: return "greaterthan.square.fill"
        case .octaveShifter: return "water.waves.and.arrow.trianglehead.up"
        case .resetter: return "arrow.trianglehead.counterclockwise"
        }
    }
    
}
