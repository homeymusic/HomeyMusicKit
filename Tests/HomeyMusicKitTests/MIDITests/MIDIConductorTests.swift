import MIDIKitIO
import MIDIKitCore
import SwiftUI
import Testing
@testable import HomeyMusicKit

@MainActor
final class MIDIConductorTests {
    
    let midiManager = ObservableMIDIManager(clientName: "TestApp", model: "Test", manufacturer: "Testing")
    var sendCurrentStateCalled = false

    lazy var midiConductor = MIDIConductor(sendCurrentState: {
        self.sendCurrentStateCalled = true
    })
    
    @Test
    func testSendCurrentState() async throws {
        // Verify initial state
        #expect(sendCurrentStateCalled == false)
        
        // Trigger sendCurrentState directly
        midiConductor.sendCurrentState?()
        
        // Verify that sendCurrentState was called
        #expect(sendCurrentStateCalled == true)
        print("sendCurrentState was triggered successfully.")
    }

    @Test
    func testSendNoteOnAndOff() async throws {
        midiConductor.setup(midiManager: midiManager)
        
        let midiNote = MIDINote(60)  // Middle C
        let channel: UInt4 = 0
        
        // Test sending note on
        midiConductor.sendNoteOn(midiNote: midiNote, midiChannel: channel)
        print("Sent Note On for \(midiNote)")

        // Test sending note off
        midiConductor.sendNoteOff(midiNote: midiNote, midiChannel: channel)
        print("Sent Note Off for \(midiNote)")
    }
    
    @Test
    func testSendTonicPitch() async throws {
        midiConductor.setup(midiManager: midiManager)
        
        let tonicNote = MIDINote(60)
        midiConductor.sendTonicPitch(midiNote: tonicNote, midiChannel: 0)
        print("Sent Tonic Pitch for \(tonicNote)")
    }
    
    @Test
    func testSendPitchDirection() async throws {
        midiConductor.setup(midiManager: midiManager)
        
        midiConductor.sendPitchDirection(upwardPitchDirection: true, midiChannel: 0)
        print("Sent Pitch Direction Up")
        
        midiConductor.sendPitchDirection(upwardPitchDirection: false, midiChannel: 0)
        print("Sent Pitch Direction Down")
    }
    
    @Test
    func testListenForStatusRequest() async {
        // Setup MIDI conductor
        midiConductor.setup(midiManager: midiManager)

        // Send the event to listenForStatusRequest
        try? midiConductor.handleStatusRequest(event: .sysEx7(rawHexString: "F07D030103F7"))
        
        // Check if the timestamp was set
        #expect(midiConductor.latestStatusRequestTimestamp != nil, "Timestamp should be set after status request")
        
        // Check if the timestamp is close to now (within a second or so)
        let timeElapsed = Date().timeIntervalSince(midiConductor.latestStatusRequestTimestamp!)
        #expect(timeElapsed < 1.0, "Timestamp should be recent (less than 1 second old)")

    }
    
    
    @Test
    func testHandleStatusRequest_DefaultPath() async {
        // Reset the timestamps
        midiConductor.latestStatusUnhandledTimestamp = nil
        
        // Setup MIDI conductor
        midiConductor.setup(midiManager: midiManager)

        // Send an unhandled MIDI event (using a valid velocity type)
        let unhandledEvent = MIDIEvent.noteOn(MIDINoteNumber(60), velocity: .midi1(127), channel: 0)

        // Call handleStatusRequest with the unhandled event
        midiConductor.handleStatusRequest(event: unhandledEvent)

        // Assert that the latestStatusUnhandledTimestamp is set
        #expect(midiConductor.latestStatusUnhandledTimestamp != nil)
        let timeElapsed = Date().timeIntervalSince(midiConductor.latestStatusUnhandledTimestamp!)
        #expect(timeElapsed < 1.0, "Timestamp should be recent (less than 1 second old)")
    }
    
    @Test
    func testSendStatusRequest() async {
        midiConductor.setup(midiManager: midiManager)
        
        // Send status request
        midiConductor.sendStatusRequest()
        
        print("sendStatusRequest successfully sent a SysEx status request")
    }
}
