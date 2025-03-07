import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

final public class MIDIConductor: MIDIConductorProtocol, ObservableObject {
    private weak var midiManager: ObservableMIDIManager?
    public var latestStatusRequestTimestamp: Date?
    public var latestStatusUnhandledTimestamp: Date?
    // This will store the reference to the `sendCurrentState` function.
    var sendCurrentState: (() -> Void)?
    
    // Custom initializer to accept the function during creation
    public init(sendCurrentState: @escaping () -> Void) {
        self.sendCurrentState = sendCurrentState
    }
    
    public func setup(midiManager: ObservableMIDIManager) {
        self.midiManager = midiManager
        
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
        guard let midiManager else { return }
        
        do {
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
        } catch {
            print("Error creating MIDI output connection:", error.localizedDescription)
        }
    }
    
    /// Convenience accessor for created MIDI Output Connection.
    public var outputConnection: MIDIOutputConnection? {
        midiManager?.managedOutputConnections[Self.outputConnectionName]
    }
    
    public func handleStatusRequest(event: MIDIEvent) {
        switch event {
        case let .sysEx7(payload):
            print("Received SysEx7: \(payload)")
            if payload.data == [3, 1, 3] {
                print("Status request received")
                currentStatus()
                latestStatusRequestTimestamp = Date()
            }
        default:
            latestStatusUnhandledTimestamp = Date()
            print("Unhandled event type")
        }
    }
    
    // Sending function: sends a SysEx status request to trigger a response on the receiving device
    public func statusRequest() {
        print("Sending status request")
        try? outputConnection?.send(event: .sysEx7(rawHexString: "F07D030103F7"))
    }
    
    // Helper function to handle the action of sending the current status
    private func currentStatus() {
        print("Sending current status")
        sendCurrentState?()
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
    
    public func modeOffset(modeOffset: Mode, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose3,
            value: .midi1(UInt7(modeOffset.rawValue)),
            channel: midiChannel
        ))
    }
    
}

public protocol MIDIConductorProtocol {
    func setup(midiManager: ObservableMIDIManager)
    func noteOn(pitch: Pitch, midiChannel: UInt4)
    func noteOff(pitch: Pitch, midiChannel: UInt4)
    func tonicPitch(pitch: Pitch, midiChannel: UInt4)
    func modeOffset(modeOffset: Mode, midiChannel: UInt4)
    func pitchDirection(pitchDirection: PitchDirection, midiChannel: UInt4)
}
