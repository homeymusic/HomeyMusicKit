import SwiftUI

public enum ContainerType {
    case basic
    case diamond
    case span
    case tonicPicker
    case tonnetz
}

// TODO: i think if we add row, col here and pass to PitchRectInfo
// we can make progress toward a general approach to dealing with
// the creation of the triad triangles.
public struct PitchContainerView: View {
    let pitch: Pitch
    let row: Int
    let col: Int
    let zIndex: Int
    let pitchView: PitchView
    
    init(
        pitch: Pitch,
        row: Int,
        col: Int,
        zIndex: Int = 0,
        containerType: ContainerType = .basic
    ) {
        self.pitch = pitch
        self.row = row
        self.col = col
        self.zIndex = zIndex
        self.pitchView = PitchView(
            pitch: pitch,
            containerType: containerType
        )
    }
    
    func rect(rect: CGRect) -> some View {
        pitchView
            .preference(
                key: PitchRectsKey.self,
                // We publish a 1-entry dictionary:
                value: [
                    InstrumentCoordinate(row: row, col: col): PitchRectInfo(
                        rect: rect,
                        midiNoteNumber: pitch.midiNote.number,
                        zIndex: zIndex
                    )
                ]
            )
    }

    public var body: some View {
        GeometryReader { proxy in
            rect(rect: proxy.frame(in: .global))
        }
    }
}
