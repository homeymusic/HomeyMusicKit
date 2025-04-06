import SwiftUI
import SwiftData
import MIDIKitCore

public struct PitchCell: View, CellProtocol {
    let pitch: Pitch
    let row: Int
    let col: Int
    let offset: Bool
    let zIndex: Int
    let cellType: CellType
    let namedCoordinateSpace: String

    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext
    @Environment(\.modelContext) var modelContext

    public init(
        pitch: Pitch,
        row: Int,
        col: Int,
        offset: Bool = false,
        zIndex: Int = 0,
        cellType: CellType = .basic,
        namedCoordinateSpace: String = HomeyMusicKit.instrumentSpace
    ) {
        self.pitch = pitch
        self.row = row
        self.col = col
        self.offset = offset
        self.zIndex = zIndex
        self.cellType = cellType
        self.namedCoordinateSpace = namedCoordinateSpace
    }

    // Layout / Appearance Variables
    
    var backgroundBorderSize: CGFloat { 3.0 }
    
    var borderWidthApparentSize: CGFloat {
        if cellType == .diamond || isSmall {
            return 2.0 * backgroundBorderSize
        } else {
            return backgroundBorderSize
        }
    }
    
    var borderHeightApparentSize: CGFloat {
        cellType == .diamond ? 2.0 * backgroundBorderSize : backgroundBorderSize
    }
    
    var outlineWidth: CGFloat {
        borderWidthApparentSize * outlineMultiplier
    }
    
    var outlineHeight: CGFloat {
        borderHeightApparentSize * outlineMultiplier
    }
    
    var alignment: Alignment {
        (instrumentalContext.instrumentChoice == .piano && cellType != .tonicPicker)
            ? .top
            : .center
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named(namedCoordinateSpace))
            Color.clear
                .preference(
                    key: OverlayCellKey.self,
                    value: [
                        InstrumentCoordinate(row: row, col: col): OverlayCell(
                            rect: rect,
                            identifier: Int(pitch.midiNote.number),
                            zIndex: zIndex,
                            layoutOffset: offset,
                            cellType: cellType
                        )
                    ]
                )
                .overlay(
                    ZStack(alignment: alignment) {
                        CellShape(fillColor: Color(HomeyMusicKit.backgroundColor),
                                 pitchCell: self,
                                 proxySize: proxy.size)
                        .overlay(alignment: alignment) {
                            if isOutlined {
                                CellShape(fillColor: outlineColor, pitchCell: self, proxySize: proxy.size)
                                    .frame(
                                        width: proxy.size.width - borderWidthApparentSize,
                                        height: proxy.size.height - borderHeightApparentSize
                                    )
                                    .overlay(alignment: alignment) {
                                        CellShape(fillColor: keyColor, pitchCell: self, proxySize: proxy.size)
                                            .frame(
                                                width: proxy.size.width - outlineWidth,
                                                height: proxy.size.height - outlineHeight
                                            )
                                    }
                            } else {
                                CellShape(fillColor: keyColor, pitchCell: self, proxySize: proxy.size)
                                    .frame(
                                        width: proxy.size.width - borderWidthApparentSize,
                                        height: proxy.size.height - borderHeightApparentSize
                                    )
                                    .padding(.leading, leadingOffset)
                                    .padding(.trailing, trailingOffset)
                            }
                        }
                    }
                    .overlay(
                        NotationView(
                            pitch: pitch,
                            pitchCell: self,
                            proxySize: proxy.size
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                )
        }
    }
    
    // Custom overrides for padding
    func topPadding(_ size: CGSize) -> CGFloat {
        (instrumentalContext.instrumentChoice == .piano && cellType != .tonicPicker)
            ? relativeCornerRadius(in: size)
            : 0.0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        (instrumentalContext.instrumentChoice == .piano && cellType != .tonicPicker)
            ? -relativeCornerRadius(in: size)
            : 0.0
    }
    
    // Custom darkenSmallKeys
    func darkenSmallKeys(color: Color) -> Color {
        if instrumentalContext.instrumentChoice == .piano && cellType != .tonicPicker {
            return isSmall ? color.adjust(brightness: -0.1) : color.adjust(brightness: +0.1)
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
        if cellType == .tonicPicker || cellType == .tonnetz {
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
            inactiveColor = pitch.isNatural ? .white : Color(Color.systemGray4)
            activeColor = pitch.isNatural ? Color(Color.systemGray) : Color(Color.systemGray6)
            return isActivated ? activeColor : inactiveColor
        }
    }
    
    var maxOutlineMultiplier: CGFloat {
        isSmall ? 2.0 : 3.0
    }
    
    var outlineMultiplier: CGFloat {
        if pitch.consonanceDissonance(for: tonalContext) == .tonic {
            return maxOutlineMultiplier
        } else if cellType == .diamond {
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
            pitch.interval(for: tonalContext).isTonic ||
            pitch.interval(for: tonalContext).isOctave ||
            (
                notationalTonicContext.showModePicker &&
                tonalContext.mode.intervalClasses.contains([pitch.interval(for: tonalContext).intervalClass])
            )
        )
    }
    
    var isSmall: Bool {
        instrumentalContext.instrumentChoice == .piano &&
        cellType != .tonicPicker &&
        !pitch.isNatural
    }
    
}
