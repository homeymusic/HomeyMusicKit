import MIDIKitCore
import MIDIKitIO
import SwiftUI
import Testing
@testable import HomeyMusicKit

@MainActor
final class TonalContextTests {
    let mockMIDIConductor = MockMIDIConductor()
    let mockSynthConductor = MockSynthConductor()
    
    // Configure the singleton with mock conductors for testing
    func setupSingleton() {
        TonalContext.shared.midiConductor = mockMIDIConductor
        TonalContext.shared.synthConductor = mockSynthConductor
        TonalContext.shared.resetToDefault()
    }
    
    @Test
    func testInitialization() async {
        setupSingleton()
        #expect(TonalContext.shared.tonicPitch == Pitch.pitch(for: Pitch.defaultTonicMIDI))
        #expect(TonalContext.shared.pitchDirection == .default)
        #expect(TonalContext.shared.isDefault == true)
    }
    
    @Test
    func testTonicPitchChange() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 64)
        #expect(mockMIDIConductor.sentTonicPitch == true)
    }
    
    @Test
    func testPitchDirectionChange() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 60)
        TonalContext.shared.pitchDirection = .downward
        #expect(TonalContext.shared.tonicPitch == Pitch.pitch(for: 72))
        #expect(mockMIDIConductor.sentPitchDirection == true)
    }
    
    @Test
    func testOctaveShiftUp() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 48)
        TonalContext.shared.shiftUpOneOctave()
        #expect(TonalContext.shared.tonicPitch == Pitch.pitch(for: 60))
    }
    
    @Test
    func testOctaveShiftDown() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 72)
        TonalContext.shared.shiftDownOneOctave()
        #expect(TonalContext.shared.tonicPitch == Pitch.pitch(for: 60))
    }
    
    @Test
    func testOctaveShiftProperty() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 60)
        TonalContext.shared.pitchDirection = .downward
        #expect(TonalContext.shared.octaveShift == 0)
    }
    
    @Test
    func testResetToDefault() async {
        setupSingleton()
        TonalContext.shared.resetToDefault()
        #expect(TonalContext.shared.isDefault == true)
    }
    
    @Test
    func testTonicRegisterNotes() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 60)  // Middle C
        TonalContext.shared.pitchDirection = .downward
        #expect(TonalContext.shared.tonicPitch == Pitch.pitch(for: 72) )
        #expect(TonalContext.shared.tonicRegisterNotes == (60...72))
    }
    
    @Test
    func testTonicMIDI() async {
        setupSingleton()
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 60)  // Middle C
        #expect(TonalContext.shared.tonicMIDI == 60) // Verify the tonic MIDI number
    }
    
    @Test
    func testNearestValidTritoneMIDI() async {
        setupSingleton()
        
        // Test when pitch direction is upward
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 0)  // C4
        TonalContext.shared.pitchDirection = .upward
        #expect(TonalContext.shared.nearestValidTritoneMIDI == 6) // Valid preferred tritone
        
        // Test when pitch direction is downward
        TonalContext.shared.tonicPitch = Pitch.pitch(for: 127)  // C4
        TonalContext.shared.pitchDirection = .downward
        #expect(TonalContext.shared.nearestValidTritoneMIDI == 121) // Valid preferred tritone
    }
}
