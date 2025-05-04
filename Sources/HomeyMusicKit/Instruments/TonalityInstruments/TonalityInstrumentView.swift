import SwiftUI

public struct TonalityInstrumentView: View {
    public let tonalityInstrument: TonalityInstrument
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }
    
    public var body: some View {
        Text("Tonality Instrument View")
    }
}
