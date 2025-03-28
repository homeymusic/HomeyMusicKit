import SwiftUI

public struct TonicPickerSettingsView: View {
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var notationalTonicContext: NotationalTonicContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    
    public init() { }
    public var body: some View {
        HStack {
            
            if notationalTonicContext.showTonicPicker {
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
                .popover(isPresented: $notationalTonicContext.showLabelsPopover,
                         content: {
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
            }
            
            Button(action: {
                withAnimation {
                    notationalTonicContext.showTonicPicker.toggle()
                }
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: notationalTonicContext.showTonicPicker ? InstrumentChoice.tonicPicker.icon + ".fill" : InstrumentChoice.tonicPicker.icon)
                            .foregroundColor(.white)
                            .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                }
                .padding(30.0)
            }
            
            if notationalTonicContext.showTonicPicker {
                Button(action: {
                    instrumentalContext.resetTonalContext(tonalContext: tonalContext)
                }) {
                    ZStack {
                        Color.clear.overlay(
                            Image(systemName: "gobackward")
                                .foregroundColor(tonalContext.isDefault ? .gray : .white)
                                .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                        )
                        .aspectRatio(1.0, contentMode: .fit)
                    }
                }
                .transition(.scale)
                .disabled(tonalContext.isDefault)
            }
        }
    }
}
