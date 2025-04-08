import SwiftUI

public struct NotationInstrumentPalletePickerView: View {
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    public init() { }
    public var body: some View {
        @Bindable var notationalContext = notationalContext
        @Bindable var instrumentalContext = instrumentalContext
        
        Group {
            
            Button(action: {
                notationalContext.showLabelsPopover.toggle()
            }) {
                ZStack {
                    Image(systemName: "tag")
                        .foregroundColor(.accentColor)
                        .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .popover(isPresented: $notationalContext.showLabelsPopover, content: {
                VStack(spacing: 0) {
                    Image(systemName: instrumentalContext.instrumentChoice.icon)
                        .padding([.top, .bottom], 7)
                    Divider()
                    ScrollView(.vertical) {
                        NotationPopoverView()
                            .presentationCompactAdaptation(.none)
                    }
                    Divider()
                    Button(action: {
                        notationalContext.resetLabels(for: instrumentalContext.instrumentChoice)
                    }, label: {
                        Image(systemName: "gobackward")
                            .gridCellAnchor(.center)
                            .foregroundColor(notationalContext.areLabelsDefault(for: instrumentalContext.instrumentChoice) ? .gray : .accentColor)
                    })
                    .padding([.top, .bottom], 7)
                    .disabled(notationalContext.areLabelsDefault(for: instrumentalContext.instrumentChoice))
                }
            })
            .padding(.trailing, 5)
            
            HStack {
                Picker("", selection: Binding(
                    get: { instrumentalContext.instrumentChoice },
                    set: { newValue in
                        // Force popover off
                        notationalContext.showPalettePopover = false
                        notationalContext.showLabelsPopover = false
                        instrumentalContext.instrumentChoice = newValue
                    }
                )) {
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
                        .foregroundColor(.accentColor)
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
                            .presentationCompactAdaptation(.none)
                    }
                    Divider()
                    Button(action: {
                        notationalContext.resetColorPaletteName(for: instrumentalContext.instrumentChoice)
                    }, label: {
                        Image(systemName: "gobackward")
                            .gridCellAnchor(.center)
                            .foregroundColor(notationalContext.isColorPaletteNameDefault(for: instrumentalContext.instrumentChoice) ? .gray : .accentColor)
                    })
                    .padding([.top, .bottom], 7)
                    .disabled(notationalContext.isColorPaletteNameDefault(for: instrumentalContext.instrumentChoice))
                    
                }
            })
            .padding(.leading, 5)
        }
    }
}
