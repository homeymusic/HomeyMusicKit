import SwiftUI
import SwiftData     // for @Bindable
import MIDIKitCore

struct StringsView<StringInstrumentProtocol: StringInstrument & PersistentModel>: View {
    @Bindable var stringInstrument: StringInstrumentProtocol
    @Bindable var tonality: Tonality

    // number of frets on the fingerboard
    let fretCount: Int = 22

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< stringInstrument.openStringsMIDI.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< fretCount + 1, id: \.self) { col in
                        // handle banjo’s short fifth string
                        if stringInstrument is Banjo
                           && row == 4 && col < 5
                        {
                            Color.clear
                        }
                        else {
                            let midiNote = stringInstrument.openStringsMIDI[row] + col
                            if Pitch.isValid(midiNote) {
                                let pitch = tonality.pitch(for: MIDINoteNumber(midiNote))
                                PitchCell(
                                    pitch: pitch,
                                    instrument: stringInstrument,
                                    row: row,
                                    col: col
                                )
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
            }
        }
    }
}
