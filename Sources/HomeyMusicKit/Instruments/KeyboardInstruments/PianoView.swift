import SwiftUI
import MIDIKitCore

struct PianoView: View {
    @ObservedObject var piano: Piano
    
    @EnvironmentObject var tonalContext: TonalContext
    
    func offset(for pitch: Pitch) -> CGFloat {
        switch pitch.pitchClass.intValue {
        case 1:
            -6.0 / 16.0
        case 3:
            -3.0 / 16.0
        case 6:
            -6.0 / 16.0
        case 8:
            -5.0 / 16.0
        case 10:
            -3.0 / 16.0
        default:
            0.0
        }
    }
    
    // MARK: - Helper for rendering a key view for a given note
    func keyView(for note: Int) -> some View {
        if Pitch.isValid(note) {
            let pitch = tonalContext.pitch(for: MIDINoteNumber(note))
            if pitch.isNatural {
                return AnyView(
                    PitchContainerView(pitch: pitch)
                        .overlay {
                            if Pitch.isValid(note - 1) {
                                let pitch = tonalContext.pitch(for: MIDINoteNumber(note - 1))
                                if !pitch.isNatural {
                                    GeometryReader { proxy in
                                        ZStack {
                                            PitchContainerView(pitch: pitch,
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
            ForEach(piano.rowIndices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(piano.nearbyNotes(
                        forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                        pitchDirection: tonalContext.pitchDirection
                    ), id: \.self) { noteClass in
                        let note = Int(noteClass) + 12 * row
                        keyView(for: note)
                    }
                }
            }
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicMIDI)
        .clipShape(Rectangle())
    }
}
