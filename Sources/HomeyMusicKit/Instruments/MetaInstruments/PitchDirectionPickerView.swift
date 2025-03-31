import SwiftUI

public struct PitchDirectionPickerView: View {
    @Environment(TonalContext.self) var tonalContext
    public init() { }
    public var body: some View {
        HStack {
            Picker("", selection: tonalContext.pitchDirectionBinding) {
                Image(systemName: PitchDirection.downward.icon)
                    .tag(PitchDirection.downward)
                Image(systemName: PitchDirection.mixed.icon)
                    .tag(PitchDirection.mixed)
                Image(systemName: PitchDirection.upward.icon)
                    .tag(PitchDirection.upward)
            }
            .frame(maxWidth: 90)
            .pickerStyle(.segmented)
        }
    }
}
