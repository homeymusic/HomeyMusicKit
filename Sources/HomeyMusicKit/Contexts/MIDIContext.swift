import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

/// A conductor responsible for managing MIDI connections and handling events.
final public class MIDIContext: ObservableObject, @unchecked Sendable {

    
    // MARK: - Dependencies & Configuration
    public let tonalContext: TonalContext
    public let instrumentMIDIChannel: MIDIChannel
    public let tonicMIDIChannel: MIDIChannel
    public let clientName: String
    public let model: String
    public let manufacturer: String
    
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
    
    public init(
        tonalContext: TonalContext,
        instrumentMIDIChannel: MIDIChannel,
        tonicMIDIChannel: MIDIChannel,
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        self.tonalContext = tonalContext
        self.instrumentMIDIChannel = instrumentMIDIChannel
        self.tonicMIDIChannel = tonicMIDIChannel
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        
        for pitch in tonalContext.allPitches {
            pitch.addOnActivateCallback { activatedPitch in
                self.noteOn(pitch: activatedPitch, midiChannel: self.instrumentMIDIChannel) // TODO: how to handle midi channel per instrument / layout?
            }
            pitch.addOnDeactivateCallback { deactivatedPitch in
                self.noteOff(pitch: deactivatedPitch, midiChannel: self.instrumentMIDIChannel)  // TODO: how to handle midi channel per instrument / layout?
            }
        }
        
        tonalContext.addDidSetTonicPitchCallbacks { oldTonicPitch, newTonicPitch in
            if (oldTonicPitch != newTonicPitch) {
                self.tonicPitch(pitch: newTonicPitch, midiChannel: self.tonicMIDIChannel)
            }
        }

        tonalContext.addDidSetPitchDirectionCallbacks { oldPitchDirection, newPitchDirection in
            if (oldPitchDirection != newPitchDirection) {
                self.pitchDirection(pitchDirection: newPitchDirection, midiChannel: self.tonicMIDIChannel)
            }
        }
        
        tonalContext.addDidSetModeCallbacks { oldMode, newMode in
            if (oldMode != newMode) {
                self.mode(mode: newMode, midiChannel: self.tonicMIDIChannel)
            }
        }
        
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
#if os(iOS)
            print("Creating MIDI input connection (iOS).")
            try midiManager.addInputConnection(
                to: .outputs(matching: [.name("IDAM MIDI Host")]),
                tag: Self.inputConnectionName,
                receiver: .events { [weak self] events, timeStamp, source in
                    guard let strongSelf = self else { return }
                    for event in events {
                        // Dispatch on the main queue for UI‐related work.
                        DispatchQueue.main.async {
                            strongSelf.receiveMIDIEvent(event: event)
                        }
                    }
                }
            )
            
            print("Creating MIDI output connection (iOS).")
            try midiManager.addOutputConnection(
                to: .inputs(matching: [.name("IDAM MIDI Host")]),
                tag: Self.outputConnectionName
            )
#elseif os(macOS)
            print("Creating MIDI input connection (macOS).")
            try midiManager.addInputConnection(
                to: .none,
                tag: "SelectedInputConnection",
                receiver: .events { [weak self] events, timeStamp, source in
                    guard let strongSelf = self else { return }
                    for event in events {
                        DispatchQueue.main.async {
                            strongSelf.receiveMIDIEvent(event: event)
                        }
                    }
                }
            )
            
            print("Creating MIDI output connection (macOS).")
            try midiManager.addOutputConnection(
                to: .allInputs,
                tag: self.clientName
            )
#endif
        } catch {
            print("Error creating MIDI output connection:", error.localizedDescription)
        }
    }
    
    // MARK: - MIDI Event Handling
    
    /// Handles incoming MIDI events.
    private func receiveMIDIEvent(event: MIDIEvent) {
        switch event {
        case let .sysEx7(payload):
            print("Received SysEx7: \(payload)")
            if payload.data == [3, 1, 3] {
                print("Status request received")
            }
        case let .cc(payload):
            print("Received CC event. Controller: \(payload.controller)")
            DispatchQueue.main.async {
                switch payload.controller {
                default:
                    print("Ignoring CC for channel \(payload.channel.intValue)")
                }
            }
        case let .noteOn(payload):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let note = MIDINoteNumber(payload.note.number.intValue)
            }
        case let .noteOff(payload):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let note = MIDINoteNumber(payload.note.number.intValue)
            }
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
        print("Sending status request")
        try? outputConnection?.send(event: .sysEx7(rawHexString: "F07D030103F7"))
    }
    
    public func noteOn(pitch: Pitch, midiChannel: UInt4) {
        try? outputConnection?.send(event: .noteOn(
            pitch.midiNote.number,
            velocity: .midi1(63),
            channel: midiChannel
        ))
    }
    
    public func noteOff(pitch: Pitch, midiChannel: UInt4) {
        try? outputConnection?.send(event: .noteOff(
            pitch.midiNote.number,
            velocity: .midi1(0),
            channel: midiChannel
        ))
    }
    
    public func tonicPitch(pitch: Pitch, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose1,
            value: .midi1(pitch.midiNote.number),
            channel: midiChannel
        ))
    }
    
    public func pitchDirection(pitchDirection: PitchDirection, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose2,
            value: .midi1(UInt7(pitchDirection.rawValue)),
            channel: midiChannel
        ))
    }
    
    public func mode(mode: Mode, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose3,
            value: .midi1(UInt7(mode.rawValue)),
            channel: midiChannel
        ))
    }
    
    // MARK: - Constants
    
    public static let inputConnectionName = "HomeyMusicKit Input Connection"
    public static let outputConnectionName = "HomeyMusicKit Output Connection"
}
