import SwiftUI

public struct ModeLabelView: View {
    var modeView: ModeCell
    var proxySize: CGSize
    
    public var body: some View {
        let topBottomPadding = modeView.isOutlined ? 0.0 : 0.5 * modeView.outlineSize
        let extraPadding = topBottomPadding
        VStack(spacing: 0.0) {
            Labels(modeView: modeView, proxySize: proxySize)
                .padding([.top, .bottom], extraPadding)
        }
    }
    
    struct Labels: View {
        let modeView: ModeCell
        let proxySize: CGSize
        
        @Environment(InstrumentalContext.self) var instrumentalContext
        @Environment(NotationalContext.self) var notationalContext
        @Environment(NotationalTonicContext.self) var notationalTonicContext
        
        var body: some View {
            VStack(spacing: 2) {
                VStack(spacing: 1) {
                    mapModeLabel
                }
            }
            .padding(2.0)
            .foregroundColor(textColor)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        }
        
        var mapModeLabel: some View {
            AnyView(
                VStack(spacing: 0.0) {
                    if notationalTonicContext.noteLabels[.tonicPicker]![.mode]! {
                        Color.clear.overlay(
                            HStack(spacing: 1.0) {
                                Text(modeView.mode.shortHand)
                                    .foregroundColor(Color(textColor))
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                            }
                                .padding(2.0)
                                .background(Color(modeView.keyColor))
                                .cornerRadius(3.0)
                        )
                    }
                    if notationalTonicContext.noteLabels[.tonicPicker]![.map]! {
                        Color.clear.overlay(
                            HStack(spacing: 1.0) {
                                mapIconImages
                            }
                                .aspectRatio(modeView.mode.scale == .pentatonic ? 3.0 : 2.0, contentMode: .fit)
                                .padding(2.0)
                                .background(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .loud ? Color(HomeyMusicKit.primaryColor) : modeView.keyColor)
                                .cornerRadius(3.0)
                        )
                    }
                }
            )
        }
        
        var mapIconImages: some View {
            Group {
                Image(systemName: "square")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.clear)
                    .overlay(
                        Image(systemName: modeView.mode.pitchDirection.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color((notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory) ? modeView.accentColor :  modeView.mode.pitchDirection.majorMinor.color))
                    )
                Image(systemName: "square")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.clear)
                    .overlay(
                        Image(systemName: modeView.mode.chordShape.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory ? modeView.accentColor : modeView.mode.chordShape.majorMinor.color))
                    )
                if modeView.mode.scale == .pentatonic {
                    Image(systemName: "square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.clear)
                        .overlay(
                            Image(systemName: Scale.pentatonic.icon)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory ? modeView.accentColor : modeView.mode.majorMinor.color))
                        )
                }
            }
        }
        
        func minDimension(_ size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
        var textColor: Color {
            switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
            case .subtle:
                return modeView.mode.majorMinor.color
            case .loud:
                return Color(HomeyMusicKit.primaryColor)
            case .ebonyIvory:
                return modeView.mode.majorMinor == .minor ? .white : .black
            }
        }

    }
    
}

