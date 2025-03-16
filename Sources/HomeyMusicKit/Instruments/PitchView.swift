import SwiftUI

public enum ContainerType {
    case basic
    case diamond
    case span
    case tonicPicker
}

public struct PitchView: View {
    
    @ObservedObject var pitch: Pitch
    let containerType: ContainerType
    
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var notationalContext: NotationalContext
    @EnvironmentObject var notationalTonicContext: NotationalTonicContext
    
    var pitchInterval: Interval {
        return tonalContext.interval(fromTonicTo: pitch)
    }
    
    var backgroundBorderSize: CGFloat {
        3.0
    }
    
    var borderWidthApparentSize: CGFloat {
        if containerType == .diamond || isSmall {
            2.0 * backgroundBorderSize
        } else {
            backgroundBorderSize
        }
    }
    
    var borderHeightApparentSize: CGFloat {
        if containerType == .diamond {
            2.0 * backgroundBorderSize
        } else {
            backgroundBorderSize
        }
    }
    
    var outlineWidth: CGFloat {
        borderWidthApparentSize * outlineMultiplier
    }
    
    var outlineHeight: CGFloat {
        if instrumentalContext.instrumentChoice == .piano && !isSmall {
            borderHeightApparentSize * outlineMultiplier / 1.5
        } else {
            borderHeightApparentSize * outlineMultiplier
        }
    }
    
    public var body: some View {
        let alignment: Alignment = instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker ? .top : .center
        GeometryReader { proxy in
            ZStack(alignment: alignment) {
                KeyRectangle(fillColor: backgroundColor, pitchView: self, proxySize: proxy.size)
                    .overlay(alignment: alignment) {
                        if outline {
                            KeyRectangle(fillColor: outlineColor, pitchView: self, proxySize: proxy.size)
                                .frame(
                                    width: proxy.size.width - borderWidthApparentSize,
                                    height: proxy.size.height - borderHeightApparentSize
                                )
                                .overlay(alignment: alignment) {
                                    KeyRectangle(fillColor: keyColor, pitchView: self, proxySize: proxy.size)
                                        .frame(
                                            width: proxy.size.width - outlineWidth,
                                            height: proxy.size.height - outlineHeight
                                        )
                                }
                        } else {
                            KeyRectangle(fillColor: keyColor, pitchView: self, proxySize: proxy.size)
                                .frame(
                                    width: proxy.size.width - borderWidthApparentSize,
                                    height: proxy.size.height - borderHeightApparentSize
                                )
                                .padding(.leading,  leadingOffset)
                                .padding(.trailing,  trailingOffset)
                        }
                    }
            }
            .overlay(PitchLabelView(
                pitchView: self,
                proxySize: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        }
    }
    
    func darkenSmallKeys(color: Color) -> Color {
        return instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker ? (isSmall ? color.adjust(brightness: -0.1) : color.adjust(brightness: +0.1)) : color
    }
    
    var accentColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            Color(HomeyMusicKit.secondaryColor)
        case .loud:
            Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            pitch.isNatural ? .black : .white
        }
    }
    
    // Local variable to check activation based on layout
    var isActivated: Bool {
        containerType == .tonicPicker ? pitch.pitchClass.isActivated(in: tonalContext.activatedPitches) : pitch.isActivated
    }
    
    var backgroundColor: Color {
        .black
    }
    
    var keyColor: Color {
        let activeColor: Color
        let inactiveColor: Color
        
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            activeColor = Color(pitchInterval.majorMinor.color)
            inactiveColor = Color(HomeyMusicKit.primaryColor)
            return isActivated ? activeColor : darkenSmallKeys(color: inactiveColor)
        case .loud:
            activeColor = Color(HomeyMusicKit.primaryColor)
            inactiveColor = Color(pitchInterval.majorMinor.color)
            return isActivated ? activeColor : inactiveColor
        case .ebonyIvory:
            inactiveColor = pitch.isNatural ? .white : Color(UIColor.systemGray4)
            activeColor   = pitch.isNatural ? Color(UIColor.systemGray) : Color(UIColor.systemGray6)
            return isActivated ? activeColor : inactiveColor
        }
    }
    
    let maxOutlineMultiplier = 3.0
    
    var outlineMultiplier: CGFloat {
        if pitchInterval.isTonic {
            return maxOutlineMultiplier
        } else if containerType == .diamond {
            return maxOutlineMultiplier * 1.0 / 2.0
        } else {
            return maxOutlineMultiplier * 2.0 / 3.0
        }
    }
    
    var outlineColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return isActivated ? Color(HomeyMusicKit.primaryColor) : pitchInterval.majorMinor.color
        case .loud:
            return isActivated ? pitchInterval.majorMinor.color : Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            return Color(MajorMinor.altNeutralColor)
        }
    }
            
    var outline: Bool {
        return notationalContext.outline[instrumentalContext.instrumentChoice]! &&
        (pitchInterval.isTonic || pitchInterval.isOctave ||
         (notationalTonicContext.showModes && containerType != .tonicPicker && tonalContext.mode.intervalClasses.contains([pitchInterval.intervalClass])))
    }
    
    var isSmall: Bool {
        instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker && !pitch.isNatural
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
        instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker ? relativeCornerRadius(in: size) : 0.0
    }
    
    func leadingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    func trailingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker ? -relativeCornerRadius(in: size) : 0.0
    }
    
    var rotation: CGFloat {
        containerType == .diamond ? 45.0 : 0.0
    }
    
    var leadingOffset: CGFloat {
        0.0
    }
    
    var trailingOffset: CGFloat {
        0.0
    }
}
