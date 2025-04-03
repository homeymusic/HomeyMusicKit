import SwiftUI
import MIDIKitCore

public enum ContainerType: Sendable {
    case basic
    case diamond
    case span
    case tonicPicker
    case tonnetz
    case swapNotation
    case piano
}
public struct PitchView: View {
    let pitch: Pitch
    let row: Int
    let col: Int
    let offset: Bool
    let zIndex: Int
    let containerType: ContainerType
    let namedCoordinateSpace: String

    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext

    // MARK: - Init

    public init(
        pitch: Pitch,
        row: Int,
        col: Int,
        offset: Bool = false,
        zIndex: Int = 0,
        containerType: ContainerType = .basic,
        namedCoordinateSpace: String = "InstrumentSpace"
    ) {
        self.pitch = pitch
        self.row = row
        self.col = col
        self.offset = offset
        self.zIndex = zIndex
        self.containerType = containerType
        self.namedCoordinateSpace = namedCoordinateSpace
    }

    // MARK: - Layout / Appearance Variables

    var backgroundBorderSize: CGFloat { 3.0 }

    var borderWidthApparentSize: CGFloat {
        if containerType == .diamond || isSmall {
            return 2.0 * backgroundBorderSize
        } else {
            return backgroundBorderSize
        }
    }

    var borderHeightApparentSize: CGFloat {
        if containerType == .diamond {
            return 2.0 * backgroundBorderSize
        } else {
            return backgroundBorderSize
        }
    }

    var outlineWidth: CGFloat {
        borderWidthApparentSize * outlineMultiplier
    }

    var outlineHeight: CGFloat {
        borderHeightApparentSize * outlineMultiplier
    }

    var alignment: Alignment {
        // For piano (except tonicPicker), align content to .top
        (instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker)
            ? .top
            : .center
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            // 1) Measure the cell’s CGRect in our named coordinate space
            let rect = proxy.frame(in: .named(self.namedCoordinateSpace))

            // 2) Publish it to our PitchRectsKey
            Color.clear
                .preference(
                    key: PitchRectsKey.self,
                    value: [
                        InstrumentCoordinate(row: row, col: col): PitchRectInfo(
                            rect: rect,
                            midiNoteNumber: pitch.midiNote.number,
                            zIndex: zIndex,
                            layoutOffset: offset,
                            containerType: containerType
                        )
                    ]
                )
                // 3) Overlay the actual pitch “key shape” (and label)
                .overlay(
                    ZStack(alignment: alignment) {
                        // Outer shape (background color)
                        KeyShape(fillColor: Color(HomeyMusicKit.backgroundColor),
                                 pitchView: self,
                                 proxySize: proxy.size)
                        .overlay(alignment: alignment) {
                            if isOutlined {
                                // Outline layer
                                KeyShape(fillColor: outlineColor, pitchView: self, proxySize: proxy.size)
                                    .frame(
                                        width:  proxy.size.width  - borderWidthApparentSize,
                                        height: proxy.size.height - borderHeightApparentSize
                                    )
                                    .overlay(alignment: alignment) {
                                        // Inner color
                                        KeyShape(fillColor: keyColor, pitchView: self, proxySize: proxy.size)
                                            .frame(
                                                width:  proxy.size.width  - outlineWidth,
                                                height: proxy.size.height - outlineHeight
                                            )
                                    }
                            } else {
                                // Directly show keyColor
                                KeyShape(fillColor: keyColor, pitchView: self, proxySize: proxy.size)
                                    .frame(
                                        width:  proxy.size.width  - borderWidthApparentSize,
                                        height: proxy.size.height - borderHeightApparentSize
                                    )
                                    .padding(.leading,  leadingOffset)
                                    .padding(.trailing, trailingOffset)
                            }
                        }
                    }
                    // Notation (label/text, etc.)
                    .overlay(
                        NotationView(
                            pitch: pitch,
                            pitchView: self,
                            proxySize: proxy.size
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                )
        }
    }

    // MARK: - Helpers

    func darkenSmallKeys(color: Color) -> Color {
        if instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker {
            return isSmall
                ? color.adjust(brightness: -0.1)
                : color.adjust(brightness: +0.1)
        } else {
            return color
        }
    }

    var accentColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return Color(HomeyMusicKit.secondaryColor)
        case .loud:
            return Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            return pitch.isNatural ? .black : .white
        }
    }

    var isActivated: Bool {
        // For some container types, we check pitchClass activation
        if containerType == .tonicPicker || containerType == .tonnetz {
            return pitch.pitchClass.isActivated(in: tonalContext.activatedPitches)
        } else {
            return pitch.isActivated
        }
    }

    var keyColor: Color {
        let activeColor: Color
        let inactiveColor: Color

        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            activeColor   = Color(pitch.majorMinor(for: tonalContext).color)
            inactiveColor = Color(HomeyMusicKit.primaryColor)
            return isActivated ? activeColor : darkenSmallKeys(color: inactiveColor)

        case .loud:
            activeColor   = Color(HomeyMusicKit.primaryColor)
            inactiveColor = Color(pitch.majorMinor(for: tonalContext).color)
            return isActivated ? activeColor : inactiveColor

        case .ebonyIvory:
            inactiveColor = pitch.isNatural
                ? .white
                : Color(Color.systemGray4)
            activeColor = pitch.isNatural
                ? Color(Color.systemGray)
                : Color(Color.systemGray6)
            return isActivated ? activeColor : inactiveColor
        }
    }

    var maxOutlineMultiplier: CGFloat {
        isSmall ? 2.0 : 3.0
    }

    var outlineMultiplier: CGFloat {
        if pitch.consonanceDissonance(for: tonalContext) == .tonic {
            return maxOutlineMultiplier
        } else if containerType == .diamond {
            return maxOutlineMultiplier / 2.0
        } else {
            return maxOutlineMultiplier * 2.0 / 3.0
        }
    }

    var outlineColor: Color {
        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
        case .subtle:
            return isActivated
                ? Color(HomeyMusicKit.primaryColor)
                : pitch.majorMinor(for: tonalContext).color
        case .loud:
            return isActivated
                ? pitch.majorMinor(for: tonalContext).color
                : Color(HomeyMusicKit.primaryColor)
        case .ebonyIvory:
            return Color(MajorMinor.altNeutralColor)
        }
    }

    var isOutlined: Bool {
        notationalContext.outline[instrumentalContext.instrumentChoice]! &&
        (
            pitch.interval(for: tonalContext).isTonic
            || pitch.interval(for: tonalContext).isOctave
            || (
                notationalTonicContext.showModePicker
                && tonalContext.mode.intervalClasses.contains(
                    [pitch.interval(for: tonalContext).intervalClass]
                )
            )
        )
    }

    var isSmall: Bool {
        instrumentalContext.instrumentChoice == .piano
        && containerType != .tonicPicker
        && !pitch.isNatural
    }

    func minDimension(_ size: CGSize) -> CGFloat {
        min(size.width, size.height)
    }

    func relativeFontSize(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.333
    }

    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.125
    }

    func topPadding(_ size: CGSize) -> CGFloat {
        (instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker)
            ? relativeCornerRadius(in: size)
            : 0.0
    }

    func leadingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }

    func trailingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }

    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        (instrumentalContext.instrumentChoice == .piano && containerType != .tonicPicker)
            ? -relativeCornerRadius(in: size)
            : 0.0
    }

    var leadingOffset: CGFloat { 0.0 }
    var trailingOffset: CGFloat { 0.0 }
}
