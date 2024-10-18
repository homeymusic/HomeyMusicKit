import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDIChannel = UInt4
public typealias MIDINoteNumber = UInt7

final public class MIDIConductor: ObservableObject {
    private weak var midiManager: ObservableMIDIManager?
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
    
    public static let inputConnectionName = "TestApp Input Connection"
    public static let outputConnectionName = "TestApp Output Connection"
    
    public  func setupConnections() {
        guard let midiManager else { return }
        
        do {
            // "IDAM MIDI Host" is the name of the MIDI input and output that iOS creates
            // on the iOS device once a user has clicked 'Enable' in Audio MIDI Setup on the Mac
            // to establish the USB audio/MIDI connection to the iOS device.
            
            print("Creating MIDI input connection.")
            try midiManager.addInputConnection(
                to: .outputs(matching: [.name("IDAM MIDI Host")]),
                tag: Self.inputConnectionName,
                receiver: .events { [weak self] events, timeStamp, source in
                    events.forEach { self?.listenForHomeyVisuals(event: $0) }
                }
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
    
    public  func listenForHomeyVisuals(event: MIDIEvent) {
        switch event {
        case let .sysEx7(payload):
            print("sysEx7 \(payload)")
            if payload.data == [3,1,3] {
                print("Satisfaction")
                sendCurrentState?()
            }
        default:
            print("other event")
        }
    }
    
    public func sendNoteOn(noteNumber: MIDINoteNumber, midiChannel: UInt4) {
        try? outputConnection?.send(event: .noteOn(
            noteNumber,
            velocity: .midi1(63),
            channel: midiChannel
        ))
    }
    
    public func sendNoteOff(noteNumber: MIDINoteNumber, midiChannel: UInt4) {
        try? outputConnection?.send(event: .noteOff(
            noteNumber,
            velocity: .midi1(0),
            channel: midiChannel
        ))
    }
    
    public func sendTonic(noteNumber: MIDINoteNumber, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose1,
            value: .midi1(noteNumber),
            channel: midiChannel
        ))

    }

    public func sendPitchDirection(upwardPitchDirection: Bool, midiChannel: UInt4) {
        try? outputConnection?.send(event: .cc(
            MIDIEvent.CC.Controller.generalPurpose2,
            value: .midi1(upwardPitchDirection ? 1 : 0),
            channel: midiChannel
        ))
    }
    
    // Safe MIDI checker function
    public static func isValidMIDI(_ note: Int) -> Bool {
        return MIDINoteNumber(exactly: note) != nil
    }
    
}
