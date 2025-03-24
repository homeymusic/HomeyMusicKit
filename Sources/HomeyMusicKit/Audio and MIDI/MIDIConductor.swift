import MIDIKitIO
import MIDIKitCore
import SwiftUI
import Combine

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

/// A conductor responsible for managing MIDI connections and handling events.
@MainActor
final public class MIDIConductor: ObservableObject {
    
    // MARK: - Dependencies & Configuration
    public let tonalContext: TonalContext
    public let tonicMIDIChannel: MIDIChannel
    public let clientName: String
    public let model: String
    public let manufacturer: String
    
    private var cancellables = Set<AnyCancellable>()
    
    private var suppressOutgoingMIDI = false
    
    private let instrumentMIDIChannelProvider: () -> MIDIChannel
    public var instrumentMIDIChannel: MIDIChannel {
        instrumentMIDIChannelProvider()
    }
    
    // MARK: - MIDI Manager Setup
    
    /// The MIDI manager used for I/O.
    private lazy var midiManager: ObservableMIDIManager = {
        ObservableMIDIManager(
            clientName: self.clientName,
            model: self.model,
            manufacturer: self.manufacturer,
            notificationHandler: { [weak self] notification in
                // Customize your notifications as needed.
                print("MIDI notification received: \(notification)")
            }
        )
    }()
    
    // MARK: - Initializer
    @MainActor
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
        
        for pitch in tonalContext.allPitches {
            pitch.$isActivated
                .removeDuplicates()
                .sink { isActivated in
                    if isActivated {
                        self.noteOn(pitch: pitch)
                    } else {
                        self.noteOff(pitch: pitch)
                    }
                }
                .store(in: &cancellables)
        }
        
        tonalContext.$tonicPitch
            .removeDuplicates()
            .sink { [weak self] newTonicPitch in
                self?.tonicPitch(pitch: newTonicPitch)
            }
            .store(in: &cancellables)
        
        tonalContext.$pitchDirection
            .removeDuplicates()
            .sink { [weak self] newPitchDirection in
                self?.pitchDirection(pitchDirection: newPitchDirection)
            }
            .store(in: &cancellables)
        
        tonalContext.$mode
            .removeDuplicates()
            .sink { [weak self] newMode in
                self?.mode(mode: newMode)
            }
            .store(in: &cancellables)
        
        self.setup()
        
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
    }
    
    /// Sets up MIDI input and output connections.
    public func setupConnections() {
        do {
            let tonalContext = self.tonalContext
            let midiConductor = self
            try midiManager.addInputConnection(
                to: .allOutputs,
                tag: Self.inputConnectionName,
                receiver: .events { events, timeStamp, source in
                    for event in events {
                        DispatchQueue.main.async {
                            Self.receiveMIDIEvent(
                                event: event,
                                tonalContext: tonalContext,
                                midiConductor: midiConductor
                            )
                        }
                    }
                }
            )
            
            print("Creating MIDI output connection (iOS).")
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
    @MainActor
    private static func receiveMIDIEvent(
        event: MIDIEvent,
        tonalContext: TonalContext,
        midiConductor: MIDIConductor
    ) {
        switch event {
        case let .sysEx7(payload):
            if payload.data == SysExConstants.statusRequestData {
                midiConductor.suppressOutgoingMIDI = true
                defer { midiConductor.suppressOutgoingMIDI = false }
                
                midiConductor.tonicPitch(pitch: tonalContext.tonicPitch)
                midiConductor.pitchDirection(pitchDirection: tonalContext.pitchDirection)
                midiConductor.mode(mode: tonalContext.mode)
            }
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
    
    /// Sends a SysEx status request.
    public func statusRequest() {
        try? outputConnection?.send(event: SysExConstants.statusRequestEvent)
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

private enum SysExConstants {
    static let manufacturer: MIDIEvent.SysExManufacturer = .educational()
    
    static let statusRequestData: [UInt8] = [0x03, 0x01, 0x03]
    
    static var statusRequestEvent: MIDIEvent {
        return try! MIDIEvent.sysEx7(manufacturer: manufacturer, data: statusRequestData)
    }
}
