import SwiftUI
import MIDIKitCore

struct DiamantiView: View {
    @ObservedObject var diamanti: Diamanti
    
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(TonalContext.self) var tonalContext: TonalContext
    
    // MARK: - Helper for rendering a key view for a given note
    func keyView(for note: Int, row: Int, col: Int) -> some View {
        let majorMinor: MajorMinor = Interval.majorMinor(forDistance: note - Int(tonalContext.tonicPitch.midiNote.number))
        if (majorMinor == .minor) {
            return AnyView(
                VStack(spacing: 0) {
                    let noteOffset: Int = 1
                    if Pitch.isValid(note + noteOffset) {
                        PitchContainerView(
                            pitch: tonalContext.pitch(for: MIDINoteNumber(note + noteOffset)),
                            row: row,
                            col: col + noteOffset
                        )
                    } else {
                        Color.clear
                    }
                    if Pitch.isValid(note) {
                        PitchContainerView(
                            pitch: tonalContext.pitch(for: MIDINoteNumber(note)),
                            row: row,
                            col: col,
                            containerType: .swapNotation
                        )
                    } else {
                        Color.clear
                    }
                }
            )
        } else if (majorMinor == .neutral) {
            let intervalClass: IntervalClass = IntervalClass(distance: note - Int(tonalContext.tonicMIDI))
            if intervalClass == .P5 {
                if Pitch.isValid(note) {
                    return AnyView(PitchContainerView(
                        pitch: tonalContext.pitch(for: MIDINoteNumber(note)),
                        row: row,
                        col: col,
                        containerType: .span
                    )
                        .overlay {
                            let noteOffset: Int = -1
                            if Pitch.isValid(note + noteOffset) && Pitch.isValid(note + noteOffset + noteOffset) {
                                GeometryReader { proxy in
                                    let ttLength = DiamantiView.tritoneLength(proxySize: proxy.size)
                                    ZStack {
                                        PitchContainerView(
                                            pitch: tonalContext.pitch(for: MIDINoteNumber(note + noteOffset)),
                                            row: row,
                                            col: col + noteOffset,
                                            zIndex: 1,
                                            containerType: .diamond
                                        )
                                        .rotationEffect(Angle(degrees: 45))
                                        .frame(width: ttLength, height: ttLength)
                                    }
                                    .offset(x: -ttLength / 2.0,
                                            y: proxy.size.height / 2.0 - ttLength / 2.0)
                                    .zIndex(1)
                                }
                            }
                        }
                    )
                } else {
                    return AnyView(Color.clear)
                }
            } else if intervalClass != .tt && Pitch.isValid(note) {
                return AnyView(PitchContainerView(
                    pitch: tonalContext.pitch(for: MIDINoteNumber(note)),
                    row: row,
                    col: col,
                    containerType: .span
                ))
            } else {
                return AnyView(EmptyView())
            }
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        VStack(spacing: 0) {
            ForEach(diamanti.rowIndices, id: \.self
            ) { row in
                HStack(spacing: 0) {
                    ForEach(diamanti.colIndices(forTonic: Int(tonalContext.tonicPitch.midiNote.number),
                                                pitchDirection: tonalContext.pitchDirection), id: \.self) { col in
                        let note = Int(col) + 12 * row
                        keyView(for: note, row: row, col: col)
                    }
                }
            }
        }
    }
    
    static func tritoneLength(proxySize: CGSize) -> CGFloat {
        return min(proxySize.height * 1/3, proxySize.width)
    }
    
}
