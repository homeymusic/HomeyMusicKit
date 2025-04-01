import SwiftUI
import MIDIKitCore

struct TonicPickerView: View {
    @Environment(TonalContext.self) var tonalContext
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tonalContext.tonicPickerNotes, id: \.self) { note in
                if Pitch.isValid(note) {
                    TonicContainerView(
                        pitch: tonalContext.pitch(for: MIDINoteNumber(note))
                    )
                } else {
                    Color.clear
                }
            }
        }
        .coordinateSpace(name: "TonicPickerSpace")
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicPitch)
    }
}
