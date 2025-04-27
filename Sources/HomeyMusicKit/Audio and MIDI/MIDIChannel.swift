import MIDIKitCore

public enum MIDIChannel: MIDIChannelNumber, CaseIterable, Identifiable, Sendable {
    case channel1 = 0
    case channel2, channel3, channel4,
         channel5, channel6, channel7, channel8,
         channel9, channel10, channel11, channel12,
         channel13, channel14, channel15, channel16
    
    
    public var id: MIDIChannelNumber { rawValue }
    public static let `default`: MIDIChannel = .channel1
    
    public var label: String { "\(rawValue + 1)" }
    public var icon: String { String(format: "%02d.square", Int(rawValue) + 1) }
}
