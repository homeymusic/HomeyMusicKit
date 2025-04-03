import SwiftUI

public struct ModeView: View, CellViewProtocol {
    
    let mode: Mode
    let row: Int
    let col: Int
    
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

    public var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named(HomeyMusicKit.modePickerSpace))
            Color.clear
                .preference(key: OverlayCellKey.self,
                            value: [
                                InstrumentCoordinate(row: row, col: col): OverlayCell(
                                    rect: rect,
                                    identifier: Int(mode.rawValue),
                                    containerType: .modePicker
                                )
                            ])
                .overlay(
                    ZStack(alignment: .center) {
                        ZStack(alignment: .center) {
                            ModeRectangle(fillColor: Color(HomeyMusicKit.backgroundColor), modeView: self, proxySize: proxy.size)
                                .overlay(alignment: .center) {
                                    if isOutlined {
                                        ModeRectangle(fillColor: outlineColor, modeView: self, proxySize: proxy.size)
                                            .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                            .overlay(alignment: .center) {
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
                                            .padding(.leading, leadingOffset)
                                            .padding(.trailing, trailingOffset)
                                    }
                                }
                        }
                    }
                )
        }
    }
    
    // Custom properties
    
    var accentColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return Color(HomeyMusicKit.secondaryColor)
        case .loud:
            return Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            return mode.majorMinor == .minor ? .white : .black
        }
    }
    
    var isActivated: Bool { false }
    
    var keyColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return Color(HomeyMusicKit.primaryColor)
        case .loud:
            return mode.majorMinor.color
        case .ebonyIvory:
            return mode.majorMinor.grayscaleColor
        }
    }
    
    var outlineSize: CGFloat {
        borderSize * _outlineSize
    }
    
    var _outlineSize: CGFloat {
        if (tonalContext.pitchDirection == .upward && col == 0) ||
            (tonalContext.pitchDirection == .downward && col == 12) {
            return 3.0
        } else {
            return 2.0
        }
    }
    
    var borderSize: CGFloat { 3.0 }
    
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
        keyColor
    }
    
    var isOutlined: Bool {
        notationalContext.outline[instrumentalContext.instrumentChoice]! &&
        (mode == tonalContext.mode)
    }
    
    var isSmall: Bool { false }
    
    // No need to override darkenSmallKeys since default behavior is acceptable.
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
