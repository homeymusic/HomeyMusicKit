import SwiftUI

public struct InstrumentAndPalletePickerView: View {
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var notationalContext: NotationalContext
    public init() { }
    public var body: some View {
        Button(action: {
            notationalContext.showLabelsPopover.toggle()
        }) {
            ZStack {
                Image(systemName: "tag")
                    .foregroundColor(.white)
                    .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    .aspectRatio(1.0, contentMode: .fit)
            }
        }
        .popover(isPresented: $notationalContext.showLabelsPopover,
                 content: {
            VStack(spacing: 0) {
                Image(systemName: instrumentalContext.instrumentChoice.icon)
                    .padding([.top, .bottom], 7)
                Divider()
                ScrollView(.vertical) {
                    PitchLabelsPopoverView()
                        .presentationCompactAdaptation(.popover)
                }
                Divider()
                Button(action: {
                    notationalContext.resetLabels(for: instrumentalContext.instrumentChoice)
                }, label: {
                    Image(systemName: "gobackward")
                        .gridCellAnchor(.center)
                        .foregroundColor(notationalContext.areLabelsDefault(for: instrumentalContext.instrumentChoice) ? .gray : .white)
                })
                .gridCellColumns(2)
                .disabled(notationalContext.areLabelsDefault(for: instrumentalContext.instrumentChoice))
                .padding([.top, .bottom], 7)
            }
        })
        .padding(.trailing, 5)
        
        HStack {
            Picker("", selection: $instrumentalContext.instrumentChoice) {
                ForEach(instrumentalContext.instruments, id:\.self) { instrument in
                    Image(systemName: instrument.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 160, maxWidth: .infinity)
                        .tag(instrument)
                }
            }
            .pickerStyle(.segmented)
        }
        
        Button(action: {
            notationalContext.showPalettePopover.toggle()
        }) {
            ZStack {
                Image(systemName: ColorPaletteChoice.subtle.icon)
                    .foregroundColor(.white)
                    .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                    .aspectRatio(1.0, contentMode: .fit)
            }
        }
        .popover(isPresented: $notationalContext.showPalettePopover,
                 content: {
            VStack(spacing: 0) {
                Image(systemName: instrumentalContext.instrumentChoice.icon)
                    .padding([.top, .bottom], 7)
                Divider()
                ScrollView(.vertical) {
                    PalettePopoverView()
                        .presentationCompactAdaptation(.popover)
                }
                
                Divider()
                
                Button(action: {
                    notationalContext.resetColorPalette(for: instrumentalContext.instrumentChoice)
                }, label: {
                    Image(systemName: "gobackward")
                        .gridCellAnchor(.center)
                        .foregroundColor(notationalContext.isColorPaletteDefault(for: instrumentalContext.instrumentChoice) ? .gray : .white)
                })
                .padding([.top, .bottom], 7)
                .disabled(notationalContext.isColorPaletteDefault(for: instrumentalContext.instrumentChoice))
                
            }
        })
        .padding(.leading, 5)
    }
}
