import SwiftUI

public struct PitchDirectionPickerView: View {
    @EnvironmentObject var tonalContext: TonalContext
    public init() { }
    public var body: some View {
        HStack {
            Picker("", selection: tonalContext.pitchDirectionBinding) {
                Image(systemName: PitchDirection.downward.icon)
                    .tag(PitchDirection.downward)
                Image(systemName: PitchDirection.upward.icon)
                    .tag(PitchDirection.upward)
            }
            .frame(maxWidth: 90)
            .pickerStyle(.segmented)
        }
    }
}
