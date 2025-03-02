import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

final public class MIDIConductor: ObservableObject {
    
    private let midiManager: ObservableMIDIManager

    public let clientName: String
    public let model: String
    public let manufacturer: String

    public init(
        clientName: String,
        model: String,
        manufacturer: String
    ) {
        self.clientName = clientName
        self.model = model
        self.manufacturer = manufacturer
        
        self.midiManager = ObservableMIDIManager(
            clientName: self.clientName,
            model: self.model,
            manufacturer: self.manufacturer,
            notificationHandler: { notification in
                // This switch handles notifications similar to your MIDINotifyProc.
                switch notification {
                case .setupChanged:
                    print("MIDI setup changed.")
                case .added:
                    print("A MIDI object was added.")
                case .removed:
                    print("A MIDI object was removed.")
                case .propertyChanged:
                    print("A MIDI object property changed.")
               default:
                    print("Unhandled MIDI notification: \(notification)")
                }
            }
        )
    }
    
    public func setup() {
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        setupConnections()
    }
    
    // MARK: - Connections
    
    public static let inputConnectionName = "HomeyMusicKit Input Connection"
    public static let outputConnectionName = "HomeyMusicKit Output Connection"
    
    public func setupConnections() {
        
        do {
            
#if os(iOS)
            // "IDAM MIDI Host" is the name of the MIDI input and output that iOS creates
            // on the iOS device once a user has clicked 'Enable' in Audio MIDI Setup on the Mac
            // to establish the USB audio/MIDI connection to the iOS device.
            
            print("Creating MIDI input connection.")
            try midiManager.addInputConnection(
                to: .outputs(matching: [.name("IDAM MIDI Host")]),
                tag: Self.inputConnectionName,
                receiver: .eventsLogging(options: [
                    .bundleRPNAndNRPNDataEntryLSB,
                    .filterActiveSensingAndClock
                ])
            )
            
            print("Creating MIDI output connection.")
            try midiManager.addOutputConnection(
                to: .inputs(matching: [.name("IDAM MIDI Host")]),
                tag: Self.outputConnectionName
            )
            
#elseif os(macOS)
            
            try midiManager.addInputConnection(
                to: .none,
                tag: "SelectedInputConnection",
                receiver: .events { events, timeStamp, source in
                    events.forEach { MIDIConductor.receiveMIDIEvent(event: $0) }
                }
            )
            
            try midiManager.addOutputConnection(
                to: .allInputs,
                tag: "homey"
            )

#endif
            
        } catch {
            print("Error creating MIDI output connection:", error.localizedDescription)
        }
    }
    
    private static func receiveMIDIEvent(event: MIDIEvent) {
        switch event {
        case let .sysEx7(payload):
            print("Received SysEx7: \(payload)")
            if payload.data == [3, 1, 3] {
                print("Status request received")
            }
        case let .cc(payload):
            print("payload.controller", payload.controller)
            print("MIDIEvent.CC.Controller.generalPurpose1", MIDIEvent.CC.Controller.generalPurpose1)
            print("MIDIEvent.CC.Controller.generalPurpose2", MIDIEvent.CC.Controller.generalPurpose2)
            DispatchQueue.main.async {
                switch payload.controller {
                case MIDIEvent.CC.Controller.generalPurpose1:
                    TonalContext.shared.tonicPitch = Pitch.pitch(for: MIDINoteNumber(payload.value.midi1Value.intValue))
                case MIDIEvent.CC.Controller.generalPurpose2:
                    TonalContext.shared.pitchDirection = PitchDirection(rawValue: payload.value.midi1Value.intValue)!
                case MIDIEvent.CC.Controller.generalPurpose3:
                    TonalContext.shared.modeOffset = Mode(rawValue: payload.value.midi1Value.intValue)!
                default:
                    print("ignoring cc \(payload.channel.intValue)")
                }
            }
        case let .noteOn(payload):
            DispatchQueue.main.async {
                Pitch.pitch(for: MIDINoteNumber(payload.note.number.intValue)).activate()
            }
        case let .noteOff(payload):
            DispatchQueue.main.async {
                Pitch.pitch(for: MIDINoteNumber(payload.note.number.intValue)).deactivate()
            }
        default:
            print("other")
        }
    }

    /// Convenience accessor for created MIDI Output Connection.
    public var outputConnection: MIDIOutputConnection? {
        midiManager.managedOutputConnections[Self.outputConnectionName]
    }
        
    // Sending function: sends a SysEx status request to trigger a response on the receiving device
    public func statusRequest() {
        print("Sending status request")
        try? outputConnection?.send(event: .sysEx7(rawHexString: "F07D030103F7"))
    }
    
//    func currentState() {
//        tonicPitch(pitch: TonalContext.shared.tonicPitch, midiChannel: LayoutChoice.tonic.midiChannel())
//        modeOffset(modeOffset: TonalContext.shared.modeOffset, midiChannel: LayoutChoice.tonic.midiChannel())
//        pitchDirection(pitchDirection: TonalContext.shared.pitchDirection, midiChannel: LayoutChoice.tonic.midiChannel())
//    }
    
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
    
    public func modeOffset(modeOffset: Mode, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose3,
            value: .midi1(UInt7(modeOffset.rawValue)),
            channel: midiChannel
        ))
    }
    
}
