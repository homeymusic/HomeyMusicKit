import SwiftUI
import MIDIKitCore

struct PianoView: View {
    @Bindable var piano: Piano
    
    @Environment(TonalContext.self) var tonalContext
    
    func offset(for pitch: Pitch) -> CGFloat {
        switch pitch.pitchClass {
        case .one:
            -6.0 / 16.0
        case .three:
            -3.0 / 16.0
        case .six:
            -6.0 / 16.0
        case .eight:
            -5.0 / 16.0
        case .ten:
            -3.0 / 16.0
        default:
            0.0
        }
    }
    
    // MARK: - Helper for rendering a key view for a given note
    func keyView(for note: Int, row: Int, col: Int) -> some View {
        if Pitch.isValid(note) {
            let pitch = tonalContext.pitch(for: MIDINoteNumber(note))
            if pitch.isNatural {
                return AnyView(
                    PitchCell(
                        pitch: pitch,
                        instrument: piano,
                        row: row,
                        col: col,
                        cellType: .piano
                    )
                    .overlay {
                        let noteOffset: Int = -1
                        if Pitch.isValid(note + noteOffset) {
                            let pitch = tonalContext.pitch(for: MIDINoteNumber(note - 1))
                            if !pitch.isNatural {
                                GeometryReader { proxy in
                                    ZStack {
                                        PitchCell(pitch: pitch,
                                                  instrument: piano,
                                                  row: row,
                                                  col: col + noteOffset,
                                                  zIndex: 1,
                                                  cellType: .piano
                                        )
                                        .frame(width: proxy.size.width / HomeyMusicKit.goldenRatio,
                                               height: proxy.size.height / HomeyMusicKit.goldenRatio)
                                    }
                                    .offset(x: offset(for: pitch) * proxy.size.width, y: 0.0)
                                    .zIndex(1)
                                }
                            }
                        }
                    }
                )
            } else {
                return AnyView(EmptyView())
            }
        } else {
            return AnyView(Color.clear)
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(piano.rowIndices.enumerated()), id: \.0) { (row, octave) in
                HStack(spacing: 0) {
                    ForEach(Array(
                        piano.colIndices(
                            forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                            pitchDirection: tonalContext.pitchDirection
                        ).enumerated()
                    ), id: \.0) { (col, offset) in
                        let note = offset + 12 * octave
                        keyView(for: note, row: row, col: col)
                    }
                }
            }
        }
    }
}
