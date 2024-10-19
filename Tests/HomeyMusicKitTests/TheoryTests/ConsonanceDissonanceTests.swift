import Testing
import SwiftUI
@testable import HomeyMusicKit

final class ConsonanceDissonanceTests {
    
    @Test func testLabel() async throws {
        #expect(ConsonanceDissonance.tonic.label == "tonic")
        #expect(ConsonanceDissonance.octave.label == "octave")
        #expect(ConsonanceDissonance.perfect.label == "perfect")
        #expect(ConsonanceDissonance.consonant.label == "consonant")
        #expect(ConsonanceDissonance.dissonant.label == "dissonant")
    }
    
    @Test func testIcon() async throws {
        #expect(ConsonanceDissonance.tonic.icon == "nitterhouse.fill")
        #expect(ConsonanceDissonance.octave.icon == "nitterhouse.fill")
        #expect(ConsonanceDissonance.perfect.icon == "triangle.fill")
        #expect(ConsonanceDissonance.consonant.icon == "diamond.fill")
        #expect(ConsonanceDissonance.dissonant.icon == "circle.fill")
    }
    
    @Test func testIsCustomIcon() async throws {
        #expect(ConsonanceDissonance.tonic.isCustomIcon == true)
        #expect(ConsonanceDissonance.octave.isCustomIcon == true)
        #expect(ConsonanceDissonance.perfect.isCustomIcon == false)
        #expect(ConsonanceDissonance.consonant.isCustomIcon == false)
        #expect(ConsonanceDissonance.dissonant.isCustomIcon == false)
    }
    
    @Test func testFontWeight() async throws {
        #expect(ConsonanceDissonance.tonic.fontWeight == .semibold)
        #expect(ConsonanceDissonance.octave.fontWeight == .regular)
        #expect(ConsonanceDissonance.perfect.fontWeight == .regular)
        #expect(ConsonanceDissonance.consonant.fontWeight == .regular)
        #expect(ConsonanceDissonance.dissonant.fontWeight == .regular)
    }
    
    @Test func testImageScale() async throws {
        #expect(ConsonanceDissonance.tonic.imageScale == 0.7)
        #expect(ConsonanceDissonance.octave.imageScale == 0.7)
        #expect(ConsonanceDissonance.perfect.imageScale == 0.6)
        #expect(ConsonanceDissonance.consonant.imageScale == 0.5)
        #expect(ConsonanceDissonance.dissonant.imageScale == 0.4)
    }
    
    @Test func testComparison() async throws {
        #expect(ConsonanceDissonance.tonic > ConsonanceDissonance.octave)
        #expect(ConsonanceDissonance.octave > ConsonanceDissonance.perfect)
        #expect(ConsonanceDissonance.perfect > ConsonanceDissonance.consonant)
        #expect(ConsonanceDissonance.consonant > ConsonanceDissonance.dissonant)
    }
} 
