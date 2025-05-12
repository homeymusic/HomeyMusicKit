import SwiftUI
import SwiftData

public struct TonalityInstrumentView: View {
    private let tonalityInstrument: TonalityInstrument
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }
    
    public var body: some View {
        TonicAndModePickersView(tonalityInstrument)
    }
    
}
