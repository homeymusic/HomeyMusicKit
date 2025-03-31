import SwiftUI

public struct TonicPickerSettingsView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    
    public init() { }
    public var body: some View {
        @Bindable var notationalTonicContext = notationalTonicContext
        HStack {
            
            Button(action: {
                notationalTonicContext.showLabelsPopover.toggle()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "tag")
                            .foregroundColor(.white)
                            .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .popover(isPresented: $notationalTonicContext.showLabelsPopover, content: {
                VStack(spacing: 0) {
                    Image(systemName: InstrumentChoice.tonicPicker.icon + ".fill")
                        .padding([.top, .bottom], 7)
                    Divider()
                    ScrollView(.vertical) {
                        TonicPickerPitchLabelsPopoverView()
                            .presentationCompactAdaptation(.popover)
                    }
                    Divider()
                    Button(action: {
                        notationalTonicContext.resetLabels(for: InstrumentChoice.tonicPicker)
                    }, label: {
                        Image(systemName: "gobackward")
                            .gridCellAnchor(.center)
                            .foregroundColor(notationalTonicContext.areLabelsDefault(for: InstrumentChoice.tonicPicker) ? .gray : .white)
                    })
                    .gridCellColumns(2)
                    .disabled(notationalTonicContext.areLabelsDefault(for: InstrumentChoice.tonicPicker))
                    .padding([.top, .bottom], 7)
                }
            })
            .transition(.scale)
            
            Button(action: {
                withAnimation {
                    notationalTonicContext.showTonicPicker.toggle()
                }
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: notationalTonicContext.showTonicPicker ? InstrumentChoice.tonicPicker.filledIcon : InstrumentChoice.tonicPicker.icon)
                            .foregroundColor(.white)
                            .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                }
                .padding(30.0)
            }
            
            Button(action: {
                withAnimation {
                    notationalTonicContext.showModePicker.toggle()
                }
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: notationalTonicContext.showModePicker ? InstrumentChoice.modePicker.filledIcon :
                                InstrumentChoice.modePicker.icon)
                            .foregroundColor(.white)
                            .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
        }
    }
}
