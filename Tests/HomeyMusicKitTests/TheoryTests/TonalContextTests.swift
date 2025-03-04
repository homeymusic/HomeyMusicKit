import MIDIKitCore
import MIDIKitIO
import SwiftUI
import Testing
@testable import HomeyMusicKit

@MainActor
final class TonalContextTests {
    // Setup a new TonalContext instance for each test.
    let tonalContext = TonalContext(
        clientName: "TestApp",
        model: "Test",
        manufacturer: "Testing"
    )
    
    lazy var midiConductor = MIDIContext(
        tonalContext: tonalContext
    )
    
    func setupContext() {
        tonalContext.resetToDefault()
    }
    
    @Test
    func testInitialization() async {
        setupContext()
        #expect(tonalContext.tonicPitch == tonalContext.pitch(for: Pitch.defaultTonicMIDINoteNumber))
        #expect(tonalContext.pitchDirection == .default)
        #expect(tonalContext.isDefault == true)
    }
    
    @Test
    func testOctaveShiftUp() async {
        setupContext()
        tonalContext.tonicPitch = tonalContext.pitch(for: 48)
        tonalContext.shiftUpOneOctave()
        #expect(tonalContext.tonicPitch == tonalContext.pitch(for: 60))
    }
    
    @Test
    func testOctaveShiftDown() async {
        setupContext()
        tonalContext.tonicPitch = tonalContext.pitch(for: 72)
        tonalContext.shiftDownOneOctave()
        #expect(tonalContext.tonicPitch == tonalContext.pitch(for: 60))
    }
    
    @Test
    func testOctaveShiftProperty() async {
        setupContext()
        tonalContext.tonicPitch = tonalContext.pitch(for: 60)
        tonalContext.pitchDirection = .downward
        #expect(tonalContext.octaveShift == 0)
    }
    
    @Test
    func testResetToDefault() async {
        setupContext()
        tonalContext.resetToDefault()
        #expect(tonalContext.isDefault == true)
    }
    
    @Test
    func testTonicRegisterNotes() async {
        setupContext()
        tonalContext.tonicPitch = tonalContext.pitch(for: 60)  // Middle C
        tonalContext.pitchDirection = .downward
        #expect(tonalContext.tonicPitch == tonalContext.pitch(for: 72))
        #expect(tonalContext.tonicPickerNotes == (60...72))
    }
    
    @Test
    func testTonicMIDI() async {
        setupContext()
        tonalContext.tonicPitch = tonalContext.pitch(for: 60)  // Middle C
        #expect(tonalContext.tonicMIDINoteNumber == 60) // Verify the tonic MIDI number
    }
}
