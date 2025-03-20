import SwiftUI
import MIDIKitCore

struct PianoView: View {
    @ObservedObject var piano: Piano
    
    @EnvironmentObject var tonalContext: TonalContext
    
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
                    PitchContainerView(
                        pitch: pitch,
                        row: row,
                        col: col
                    )
                        .overlay {
                            let noteOffset: Int = -1
                            if Pitch.isValid(note + noteOffset) {
                                let pitch = tonalContext.pitch(for: MIDINoteNumber(note - 1))
                                if !pitch.isNatural {
                                    GeometryReader { proxy in
                                        ZStack {
                                            PitchContainerView(pitch: pitch,
                                                               row: row,
                                                               col: col + noteOffset,
                                                               zIndex: 1)
                                            .frame(width: proxy.size.width / HomeyMusicKit.goldenRatio,
                                                   height: proxy.size.height / HomeyMusicKit.goldenRatio)
                                        }
                                        .offset(x: offset(for: pitch) * proxy.size.width, y: 0.0)
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
                        let _print1 = print("row:", row, "col:", col)
                        let _print2 = print("octave:", octave, "offset:", offset)
                        // Now you can use both indices and data
                        let note = offset + 12 * octave
                        keyView(for: note, row: row, col: col)
                    }
                }
            }        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
