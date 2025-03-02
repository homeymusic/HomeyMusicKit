import MIDIKitIO
import MIDIKitCore
import SwiftUI
import Testing
@testable import HomeyMusicKit

@MainActor
final class MIDIConductorTests {
    
    let tonalContext = TonalContext(
        clientName: "TestApp",
        model: "Test",
        manufacturer: "Testing"
    )
    
    lazy var midiConductor = MIDIConductor(
        tonalContext: tonalContext
    )
    
    @Test
    func testSendNoteOnAndOff() async throws {
        midiConductor.setup()
        
        let midiNote = MIDINoteNumber(60)  // Middle C
        let channel: UInt4 = 0
        
        // Test sending note on
        midiConductor.noteOn(pitch: tonalContext.pitch(for: midiNote), midiChannel: channel)
        print("Sent Note On for \(midiNote)")

        // Test sending note off
        midiConductor.noteOff(pitch: tonalContext.pitch(for: midiNote), midiChannel: channel)
        print("Sent Note Off for \(midiNote)")
    }
    
    @Test
    func testSendTonicPitch() async throws {
        midiConductor.setup()
        
        let tonicNote = MIDINoteNumber(60)
        midiConductor.tonicPitch(pitch: tonalContext.pitch(for: tonicNote), midiChannel: 0)
        print("Sent Tonic Pitch for \(tonicNote)")
    }
    
    @Test
    func testSendPitchDirection() async throws {
        midiConductor.setup()
        
        midiConductor.pitchDirection(pitchDirection: PitchDirection.upward, midiChannel: 0)
        print("Sent Pitch Direction Up")
        
        midiConductor.pitchDirection(pitchDirection: PitchDirection.downward, midiChannel: 0)
        print("Sent Pitch Direction Down")
    }
        
    @Test
    func testSendStatusRequest() async {
        midiConductor.setup()
        
        // Send status request
        midiConductor.statusRequest()
        
        print("sendStatusRequest successfully sent a SysEx status request")
    }
}
