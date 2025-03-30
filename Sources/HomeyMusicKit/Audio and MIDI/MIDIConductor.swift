import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

@MainActor
@Observable
final public class MIDIConductor {
    
    // MARK: - Dependencies & Configuration
    public let tonalContext: TonalContext
    public let tonicMIDIChannel: MIDIChannel
    public let clientName: String
    public let model: String
    public let manufacturer: String
    
    private var suppressOutgoingMIDI = false
    
    private let instrumentMIDIChannelProvider: () -> MIDIChannel
    public var instrumentMIDIChannel: MIDIChannel {
        instrumentMIDIChannelProvider()
    }
    
    // MARK: - MIDI Manager Setup
    private let midiManager: ObservableMIDIManager
        
    // MARK: - Initializer
    public init(
        tonalContext: TonalContext,
        instrumentMIDIChannelProvider: @escaping () -> MIDIChannel,
        tonicMIDIChannel: MIDIChannel,
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        self.tonalContext = tonalContext
        self.instrumentMIDIChannelProvider = instrumentMIDIChannelProvider
        self.tonicMIDIChannel = tonicMIDIChannel
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        
        // Initialize MIDI Manager here
        self.midiManager = ObservableMIDIManager(
            clientName: self.clientName,
            model: self.model,
            manufacturer: self.manufacturer,
            notificationHandler: { notification in
                // This closure is on whichever queue MIDIKit uses, but we have [weak self].
                // If you need to do UI / main-actor work, dispatch to main or use self? safely.
                print("MIDI notification received: \(notification)")
            }
        )

        // 2. Assign callbacks for context properties
        tonalContext.onTonicPitchChanged = { [weak self] newTonicPitch in
            self?.tonicPitch(pitch: newTonicPitch)
        }
        tonalContext.onPitchDirectionChanged = { [weak self] newPitchDirection in
            self?.pitchDirection(pitchDirection: newPitchDirection)
        }
        tonalContext.onModeChanged = { [weak self] newMode in
            self?.mode(mode: newMode)
        }

    }
    
    // MARK: - Setup Methods
    
    /// Starts the MIDI services and sets up connections.
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
        
    public func setupConnections() {
        do {
            try midiManager.addInputConnection(
                to: .allOutputs,
                tag: Self.inputConnectionName,
                // 1) Use [weak self] capture list.
                receiver: .events { [weak self] events, timeStamp, source in
                    // 2) We’re in a background (sendable) context here.
                    // So we can’t directly capture `TonalContext`.
                    // Instead, hop to the main actor with an async task:
                    guard let self = self else { return }
                    
                    Task { @MainActor in
                        // Now we’re on the main actor
                        // We can safely reference self.tonalContext,
                        // because self is @MainActor
                        for event in events {
                            Self.receiveMIDIEvent(
                                event: event,
                                tonalContext: self.tonalContext,
                                midiConductor: self
                            )
                        }
                    }
                }
            )
            
            try midiManager.addOutputConnection(
                to: .allInputs,
                tag: Self.outputConnectionName
            )
            
        } catch {
            print("Error creating MIDI output connection:", error.localizedDescription)
        }

    }
    
    // MARK: - MIDI Event Handling
    
    /// Handles incoming MIDI events.
    private static func receiveMIDIEvent(
        event: MIDIEvent,
        tonalContext: TonalContext,
        midiConductor: MIDIConductor
    ) {
        switch event {
        case let .sysEx7(payload):
            if payload.data.starts(with: [0x03, 0x01, 0x03]),
               let receivedID = payload.extractUniqueID(fromBaseLength: 3) {
                if receivedID == midiConductor.uniqueID {
                    return
                }
            }
            midiConductor.tonicPitch(pitch: tonalContext.tonicPitch)
            midiConductor.pitchDirection(pitchDirection: tonalContext.pitchDirection)
            midiConductor.mode(mode: tonalContext.mode)

        case let .cc(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            switch payload.controller {
            case .generalPurpose1:
                let pitch = tonalContext.pitch(for: MIDINoteNumber(exactly: payload.value.midi1Value)!)
                tonalContext.tonicPitch = pitch
            case .generalPurpose2:
                let pitchDirection = PitchDirection(rawValue: Int(payload.value.midi1Value))!
                tonalContext.pitchDirection = pitchDirection
            case .generalPurpose3:
                let mode = Mode(rawValue: Int(payload.value.midi1Value))!
                tonalContext.mode = mode
            default:
                print("Ignoring CC for channel \(payload.channel.intValue)")
            }
        case let .noteOn(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            
            tonalContext.pitch(for: MIDINoteNumber(payload.note.number)).activate()
        case let .noteOff(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            
            tonalContext.pitch(for: MIDINoteNumber(payload.note.number)).deactivate()
        default:
            print("Unhandled MIDI event: \(event)")
        }
    }
    
    // MARK: - Output Connection Access
    
    /// A convenience accessor for the created MIDI output connection.
    public var outputConnection: MIDIOutputConnection? {
        midiManager.managedOutputConnections[Self.outputConnectionName]
    }
    
    // MARK: - MIDI Command Methods
    private let uniqueID: [UInt8] = (0..<4).map { _ in UInt8.random(in: 0...127) }

    /// Sends a SysEx status request.
    public func statusRequest() {
        if let event = try? MIDIEvent.SysEx7.statusRequestEvent(withUniqueID: uniqueID) {
            try? outputConnection?.send(event: event)
        }
    }
    
    public func noteOn(pitch: Pitch) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(event: .noteOn(
            pitch.midiNote.number,
            velocity: .midi1(63),
            channel: instrumentMIDIChannel
        ))
    }
    
    public func noteOff(pitch: Pitch) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(event: .noteOff(
            pitch.midiNote.number,
            velocity: .midi1(0),
            channel: instrumentMIDIChannel
        ))
    }
    
    public func tonicPitch(pitch: Pitch) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose1,
            value: .midi1(pitch.midiNote.number),
            channel: instrumentMIDIChannel
        ))
    }
    
    public func pitchDirection(pitchDirection: PitchDirection) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose2,
            value: .midi1(UInt7(pitchDirection.rawValue)),
            channel: instrumentMIDIChannel
        ))
    }
    
    public func mode(mode: Mode) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose3,
            value: .midi1(UInt7(mode.rawValue)),
            channel: instrumentMIDIChannel
        ))
    }
    
    // MARK: - Constants
    
    public static let inputConnectionName = "HomeyMusicKit Input Connection"
    public static let outputConnectionName = "HomeyMusicKit Output Connection"
}

extension MIDIEvent.SysEx7 {
    /// Creates a SysEx7 status request event that appends the provided unique ID bytes.
    static func statusRequestEvent(
        withUniqueID uniqueID: [UInt8],
        manufacturer: MIDIEvent.SysExManufacturer = .educational(),
        baseData: [UInt8] = [0x03, 0x01, 0x03], // 313 is the HomeyMusicKit code to request status of the tonal context
        group: UInt4 = 0x0
    ) throws -> MIDIEvent {
        var data = baseData
        data.append(contentsOf: uniqueID)
        return try MIDIEvent.sysEx7(manufacturer: manufacturer, data: data, group: group)
    }
    
    /// Extracts the unique ID bytes from this SysEx7 event.
    func extractUniqueID(fromBaseLength baseLength: Int = 3, idLength: Int = 4) -> [UInt8]? {
        guard data.count >= baseLength + idLength else { return nil }
        return Array(data[baseLength..<baseLength+idLength])
    }
}
