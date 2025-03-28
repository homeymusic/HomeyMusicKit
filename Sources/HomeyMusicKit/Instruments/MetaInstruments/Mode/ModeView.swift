import SwiftUI

public struct ModeView: View {
    
    let mode: Mode
    let columnIndex: Int
    
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var notationalContext: NotationalContext

    public var body: some View {
        let alignment: Alignment = .center
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                
                ZStack(alignment: alignment) {
                    ModeRectangle(fillColor: Color(HomeyMusicKit.backgroundColor), modeView: self, proxySize: proxy.size)
                        .overlay(alignment: alignment) {
                            if outline {
                                ModeRectangle(fillColor: outlineColor, modeView: self, proxySize: proxy.size)
                                    .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                    .overlay(alignment: alignment) {
                                        ModeRectangle(fillColor: outlineKeyColor, modeView: self, proxySize: proxy.size)
                                            .frame(width: proxy.size.width - outlineSize, height: proxy.size.height - outlineSize)
                                            .overlay(ModeLabelView(modeView: self, proxySize: proxy.size)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity))
                                    }
                            } else {
                                ModeRectangle(fillColor: keyColor, modeView: self, proxySize: proxy.size)
                                    .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                    .overlay(ModeLabelView(modeView: self, proxySize: proxy.size)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity))
                                    .padding(.leading,  leadingOffset)
                                    .padding(.trailing,  trailingOffset)
                            }
                        }
                }
            }
            
        }
    }
    
    func darkenSmallKeys(color: Color) -> Color {
        return color
    }
    
    var accentColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            Color(HomeyMusicKit.secondaryColor)
        case .loud:
            Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            mode.majorMinor == .minor ? .white : .black
        }
    }
        
    // Local variable to check activation based on layout
    var isActivated: Bool {
        false
    }

    var keyColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return Color(HomeyMusicKit.primaryColor)
        case .loud:
            return mode.majorMinor.color
        case .ebonyIvory:
            return mode.majorMinor == .minor ? Color.systemGray4 : .white

        }
    }

    var outlineSize: CGFloat {
        borderSize * _outlineSize
    }
            
    var _outlineSize: CGFloat {
        if (tonalContext.pitchDirection == .upward && columnIndex == 0) ||
            (tonalContext.pitchDirection == .downward && columnIndex == 12) {
            return 3.0
        } else {
            return 2.0
        }
    }
    
    var borderSize: CGFloat {
        3.0
    }
    
    var outlineColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return Color(mode.majorMinor.color)
        case .loud:
            return Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            return Color(MajorMinor.altNeutralColor)
        }
    }

    var outlineKeyColor: Color {
        return keyColor
    }
    
    var outline: Bool {
        notationalContext.outline[instrumentalContext.instrumentChoice]! && (mode == tonalContext.mode)
    }
    
    var isSmall: Bool {
        false
    }
    
    func minDimension(_ size: CGSize) -> CGFloat {
        return min(size.width, size.height)
    }
    
    // How much of the key height to take up with label
    func relativeFontSize(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.333
    }
    
    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.125
    }
    
    func topPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    func leadingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    func trailingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    var leadingOffset: CGFloat {
        0.0
    }
    
    var trailingOffset: CGFloat {
        0.0
    }
}

struct ModeRectangle: View {
    var fillColor: Color
    var modeView: ModeView
    var proxySize: CGSize
    
    var body: some View {
        Rectangle()
            .fill(fillColor)
            .padding(.top, modeView.topPadding(proxySize))
            .padding(.leading, modeView.leadingPadding(proxySize))
            .padding(.trailing, modeView.trailingPadding(proxySize))
            .cornerRadius(modeView.relativeCornerRadius(in: proxySize))
            .padding(.top, modeView.negativeTopPadding(proxySize))
    }
}
