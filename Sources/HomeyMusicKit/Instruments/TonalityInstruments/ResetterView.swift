import SwiftUI
import HomeyMusicKit

public struct ResetterView: View {
    @Bindable public var tonality: Tonality
    @Bindable public var tonalityInstrument: TonalityInstrument
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
        self.tonality = tonalityInstrument.tonality
    }
    
    public var body: some View {
        if tonalityInstrument.showResetter {
            HStack(spacing: 0) {
                Button(action: {
                    tonalityInstrument.resetTonality()
                    buzz()
                }) {
                    ZStack {
                        Color.clear.overlay(
                            Image(systemName: TonalityControlType.resetter.icon)
                                .foregroundColor(tonality.isDefaultTonality ? .gray : .white)
                                .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                        )
                        .aspectRatio(1.0, contentMode: .fit)
                    }
                }
                .transition(.scale)
                .disabled(tonality.isDefaultTonality)
            }
        }
    }
}
