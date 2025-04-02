import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

@MainActor
@Observable
public final class MIDIConductor {
    
    // MARK: - Callbacks from Incoming MIDI
    
    /// Called when a Note On is received.
    public var onNoteOnReceived: ((MIDINoteNumber) -> Void)?
    
    /// Called when a Note Off is received.
    public var onNoteOffReceived: ((MIDINoteNumber) -> Void)?
    
    /// Called when a "tonic pitch" CC is received.
    public var onTonicPitchReceived: ((MIDINoteNumber) -> Void)?
    
    /// Called when a "pitch direction" CC is received.
    public var onPitchDirectionReceived: ((MIDINoteNumber) -> Void)?
    
    /// Called when a "mode" CC is received.
    public var onModeReceived: ((MIDINoteNumber) -> Void)?
    
    /// Called when a SysEx status request is received from another device.
    public var onStatusRequestReceived: (() -> Void)?
    
    // MARK: - MIDI Manager & Config
    
    public let clientName: String
    public let model: String
    public let manufacturer: String
    
    private var suppressOutgoingMIDI = false
    private let midiManager: ObservableMIDIManager
    
    // MARK: - Initialization
    
    /// Creates a `MIDIConductor` that manages MIDI in/out, exposing callbacks for incoming events
    /// and providing methods for sending outgoing MIDI events on any channel.
    public init(
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        
        // Initialize MIDI Manager
        self.midiManager = ObservableMIDIManager(
            clientName: clientName,
            model: model,
            manufacturer: manufacturer,
            notificationHandler: { notification in
                print("MIDI notification received: \(notification)")
            }
        )
    }
    
    // MARK: - Setup
    
    /// Starts MIDI services and sets up connections for receiving / sending.
    public func setup() {
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        
        setupConnections()
        statusRequest()
    }
    
    private func setupConnections() {
        do {
            try midiManager.addInputConnection(
                to: .allOutputs,
                tag: Self.inputConnectionName,
                receiver: .events { [weak self] events, _, _ in
                    guard let self = self else { return }
                    Task { @MainActor in
                        // Process MIDI events on the main actor.
                        for event in events {
                            Self.receiveMIDIEvent(event, from: self)
                        }
                    }
                }
            )
            
            try midiManager.addOutputConnection(
                to: .allInputs,
                tag: Self.outputConnectionName
            )
        } catch {
            print("Error creating MIDI connections:", error.localizedDescription)
        }
    }
    
    // MARK: - Handling Incoming MIDI
    
    private static func receiveMIDIEvent(_ event: MIDIEvent, from conductor: MIDIConductor) {
        switch event {
        case let .sysEx7(payload):
            // If it's from ourselves, ignore:
            if payload.data.starts(with: [0x03, 0x01, 0x03]),
               let receivedID = payload.extractUniqueID(fromBaseLength: 3),
               receivedID == conductor.uniqueID {
                return
            }
            // Otherwise, treat as a status request
            conductor.onStatusRequestReceived?()
            
        case let .cc(payload):
            conductor.suppressOutgoingMIDI = true
            defer { conductor.suppressOutgoingMIDI = false }
            
            switch payload.controller {
            case .generalPurpose1:
                conductor.onTonicPitchReceived?(payload.value.midi1Value)
            case .generalPurpose2:
                conductor.onPitchDirectionReceived?(payload.value.midi1Value)
            case .generalPurpose3:
                conductor.onModeReceived?(payload.value.midi1Value)
            default:
                print("Ignoring other CC: \(payload.controller)")
            }
            
        case let .noteOn(payload):
            conductor.suppressOutgoingMIDI = true
            defer { conductor.suppressOutgoingMIDI = false }
            
            conductor.onNoteOnReceived?(payload.note.number)
            
        case let .noteOff(payload):
            conductor.suppressOutgoingMIDI = true
            defer { conductor.suppressOutgoingMIDI = false }
            
            conductor.onNoteOffReceived?(payload.note.number)
            
        default:
            print("Unhandled MIDI event: \(event)")
        }
    }
    
    // MARK: - Connection Access
    
    public var outputConnection: MIDIOutputConnection? {
        midiManager.managedOutputConnections[Self.outputConnectionName]
    }
    
    // MARK: - Sending Outgoing MIDI
    
    private let uniqueID: [UInt8] = (0..<4).map { _ in UInt8.random(in: 0...127) }
    
    /// Sends a SysEx status request to all listening MIDI outputs.
    public func statusRequest() {
        if let event = try? MIDIEvent.SysEx7.statusRequestEvent(withUniqueID: uniqueID) {
            try? outputConnection?.send(event: event)
        }
    }
    
    /// Sends a MIDI note-on event on the specified channel.
    public func noteOn(pitch: Pitch, channel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .noteOn(
                pitch.midiNote.number,
                velocity: .midi1(64),
                channel: channel
            )
        )
    }
    
    /// Sends a MIDI note-off event on the specified channel.
    public func noteOff(pitch: Pitch, channel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .noteOff(
                pitch.midiNote.number,
                velocity: .midi1(0),
                channel: channel
            )
        )
    }
    
    /// Sends a CC message for tonic pitch on the specified channel.
    public func tonicPitch(_ pitch: Pitch, channel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose1,
                value: .midi1(pitch.midiNote.number),
                channel: channel
            )
        )
    }
    
    /// Sends a CC message for pitch direction on the specified channel.
    public func pitchDirection(_ direction: PitchDirection, channel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose2,
                value: .midi1(UInt7(direction.rawValue)),
                channel: channel
            )
        )
    }
    
    /// Sends a CC message for mode on the specified channel.
    public func mode(_ mode: Mode, channel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose3,
                value: .midi1(UInt7(mode.rawValue)),
                channel: channel
            )
        )
    }
    
    // MARK: - Constants
    
    public static let inputConnectionName = "HomeyMusicKit Input Connection"
    public static let outputConnectionName = "HomeyMusicKit Output Connection"
}

// MARK: - SysEx Helper Extensions

extension MIDIEvent.SysEx7 {
    static func statusRequestEvent(
        withUniqueID uniqueID: [UInt8],
        manufacturer: MIDIEvent.SysExManufacturer = .educational(),
        baseData: [UInt8] = [0x03, 0x01, 0x03], // "HomeyMusicKit code"
        group: UInt4 = 0x0
    ) throws -> MIDIEvent {
        var data = baseData
        data.append(contentsOf: uniqueID)
        return try .sysEx7(manufacturer: manufacturer, data: data, group: group)
    }
    
    func extractUniqueID(fromBaseLength baseLength: Int = 3, idLength: Int = 4) -> [UInt8]? {
        guard data.count >= baseLength + idLength else { return nil }
        return Array(data[baseLength ..< baseLength + idLength])
    }
}
