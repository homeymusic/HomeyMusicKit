import SwiftUI
import MIDIKitCore

struct TonicPickerView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument

    var body: some View {
        let row = 0
        HStack(spacing: 0) {
            ForEach(Array(tonalityInstrument.midiNoteInts.enumerated()), id: \.offset) { col, note in
                if Pitch.isValid(note) {
                    let pitch = tonalityInstrument.pitch(for: MIDINoteNumber(note))
                    PitchCell(
                        pitch: pitch,
                        instrument: tonalityInstrument,
                        row: row,
                        col: col,
                        cellType: .tonicPicker,
                        namedCoordinateSpace: HomeyMusicKit.tonicPickerSpace
                    )
                    .id(pitch.midiNote.number)
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: HomeyMusicKit.tonicPickerSpace)
        .animation(HomeyMusicKit.animationStyle, value: tonalityInstrument.tonicPitch)
    }
}
