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
                        .foregroundColor(.white)
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
                            .foregroundColor(notationalContext.areLabelsDefault(for: instrumentalContext.instrumentChoice) ? .gray : .white)
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
                        notationalContext.showColorPalettePopover = false
                        notationalContext.showEditColorPaletteSheet = false
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
                notationalContext.showColorPalettePopover.toggle()
                notationalContext.showEditColorPaletteSheet = false
            }) {
                ZStack {
                    Image(systemName: "paintpalette")
                        .foregroundColor(.white)
                        .font(Font.system(size: .leastNormalMagnitude, weight: .thin))
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .popover(isPresented: $notationalContext.showColorPalettePopover,
                     content: {
                VStack(spacing: 0) {
                    Image(systemName: instrumentalContext.instrumentChoice.icon)
                        .padding([.top, .bottom], 7)
                    Divider()
                    ScrollView(.vertical) {
                        ColorPalettePopoverView()
                            .presentationCompactAdaptation(.none)
                    }
                    Divider()
                    ZStack {
                        HStack {
                            Spacer()
                            Button("", systemImage: "paintbrush.pointed", action: {
                                notationalContext.showEditColorPaletteSheet = true
                            })
                            .sheet(isPresented: $notationalContext.showEditColorPaletteSheet) {
                                ColorPaletteManagerView()
                            }
                            .padding([.top, .bottom], 7)
                            .padding(.trailing, 7)
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                notationalContext.resetColorPalette(for: instrumentalContext.instrumentChoice)
                            }, label: {
                                Image(systemName: "gobackward")
                                    .foregroundColor(notationalContext.isColorPaletteDefault(for: instrumentalContext.instrumentChoice) ? .gray : .white)
                            })
                            .padding([.top, .bottom], 7)
                            .disabled(notationalContext.isColorPaletteDefault(for: instrumentalContext.instrumentChoice))
                            Spacer()
                        }
                    }
                }
            })
            .padding(.leading, 5)
        }
    }
}
