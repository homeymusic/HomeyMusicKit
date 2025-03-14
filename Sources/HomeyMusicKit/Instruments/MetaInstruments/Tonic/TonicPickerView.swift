import SwiftUI
import MIDIKitCore

struct TonicPickerView: View {
    @EnvironmentObject var tonalContext: TonalContext
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tonalContext.tonicPickerNotes, id: \.self) { note in
                if Pitch.isValid(note) {
                    TonicContainerView(
                        pitch: tonalContext.pitch(for: MIDINoteNumber(note)),
                        containerType: .tonicPicker
                    )
                } else {
                    Color.clear
                }
            }
        }
        .animation(HomeyMusicKit.animationStyle, value: tonalContext.tonicPitch)
        .clipShape(Rectangle())
    }
}
