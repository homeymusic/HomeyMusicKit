import SwiftUI
import SwiftData

public struct TonicPitchStatusView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument
    @Bindable public var tonality: Tonality

    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
        self.tonality = tonalityInstrument.tonality
    }

    public var body: some View {
        let row = 0
        HStack(spacing: 0) {
            PitchCell(
                pitch: tonalityInstrument.tonicPitch,
                instrument: tonalityInstrument,
                row: 0,
                col: 0,
                cellType: .basic,
                namedCoordinateSpace: HomeyMusicKit.tonicPickerSpace
            )
            .id(tonalityInstrument.tonicPitch.midiNote.number)
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonalityInstrument.tonicPitch)
    }
}
