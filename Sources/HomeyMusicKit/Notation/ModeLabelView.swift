import SwiftUI

public struct ModeLabelView: View {
    var modeCell: ModeCell
    var proxySize: CGSize
    
    public var body: some View {
        let topBottomPadding = modeCell.isOutlined ? 0.0 : 0.5 * modeCell.outlineSize
        let extraPadding = topBottomPadding
        VStack(spacing: 0.0) {
            Labels(modeCell: modeCell, proxySize: proxySize)
                .padding([.top, .bottom], extraPadding)
        }
    }
    
    struct Labels: View {
        let modeCell: ModeCell
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
            .foregroundColor(modeCell.textColor(
                majorMinor: modeCell.mode.majorMinor,
                isNatural: modeCell.mode.isNatural
            ))
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        }
        
        var mapModeLabel: some View {
            AnyView(
                VStack(spacing: 0.0) {
                    if notationalTonicContext.noteLabels[.tonicPicker]![.mode]! {
                        Color.clear.overlay(
                            HStack(spacing: 1.0) {
                                Text(modeCell.mode.shortHand)
                                    .foregroundColor(Color(modeCell.textColor(
                                        majorMinor: modeCell.mode.majorMinor,
                                        isNatural: modeCell.mode.isNatural
                                    )))
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                            }
                                .padding(2.0)
                                .background(Color(modeCell.cellColor(majorMinor: modeCell.mode.majorMinor, isNatural: modeCell.mode.isNatural)))
                                .cornerRadius(3.0)
                        )
                    }
                    if notationalTonicContext.noteLabels[.tonicPicker]![.map]! {
                        Color.clear.overlay(
                            HStack(spacing: 1.0) {
                                mapIconImages
                            }
                                .aspectRatio(modeCell.mode.scale == .pentatonic ? 3.0 : 2.0, contentMode: .fit)
                                .padding(2.0)
                                .background(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .loud ? Color(HomeyMusicKit.primaryColor) : modeCell.cellColor(majorMinor: modeCell.mode.majorMinor, isNatural: modeCell.mode.isNatural))
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
                        Image(systemName: modeCell.mode.pitchDirection.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color((notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory) ? modeCell.accentColor :  modeCell.mode.pitchDirection.majorMinor.color))
                    )
                Image(systemName: "square")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.clear)
                    .overlay(
                        Image(systemName: modeCell.mode.chordShape.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory ? modeCell.accentColor : modeCell.mode.chordShape.majorMinor.color))
                    )
                if modeCell.mode.scale == .pentatonic {
                    Image(systemName: "square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.clear)
                        .overlay(
                            Image(systemName: Scale.pentatonic.icon)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(notationalContext.colorPalette[instrumentalContext.instrumentChoice]! == .ebonyIvory ? modeCell.accentColor : modeCell.mode.majorMinor.color))
                        )
                }
            }
        }
        
        func minDimension(_ size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
    }
    
}

