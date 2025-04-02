import SwiftUI
import MIDIKitCore

struct StringsView: View {
    @Environment(TonalContext.self) var tonalContext
    @ObservedObject var stringInstrument: StringInstrument

    let fretCount: Int = 22
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< stringInstrument.openStringsMIDI.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< fretCount + 1, id: \.self) { col in
                        if (stringInstrument.instrumentChoice == .banjo && row == 4 && col < 5) {
                            Color.clear
                        } else {
                            let note = stringInstrument.openStringsMIDI[row] + col
                            if (Pitch.isValid(note)) {
                                let pitch = tonalContext.pitch(for: MIDINoteNumber(note))
                                PitchView(
                                    pitch: pitch,
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
