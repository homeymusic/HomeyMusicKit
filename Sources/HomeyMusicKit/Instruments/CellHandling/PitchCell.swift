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
    @Environment(\.modelContext) private var modelContext
    @State private var colorPalette: ColorPalette?

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
                                        CellShape(fillColor: cellColor, pitchCell: self, proxySize: proxy.size)
                                            .frame(
                                                width: proxy.size.width - outlineWidth,
                                                height: proxy.size.height - outlineHeight
                                            )
                                    }
                            } else {
                                CellShape(fillColor: cellColor, pitchCell: self, proxySize: proxy.size)
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
        .onAppear {
            fetchColorPalette()
        }
        .onChange(of: notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]) {
            fetchColorPalette()
        }
    }
    
    private func fetchColorPalette() {
        let colorPaletteName = notationalContext.colorPaletteName[instrumentalContext.instrumentChoice]
        
        let descriptor = FetchDescriptor<ColorPalette>(
            predicate: #Predicate { palette in
                palette.name == colorPaletteName!
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            colorPalette = results.first
        } catch {
            // Handle or log error
            colorPalette = nil
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
    
    func adjustCellBrightness(color: Color) -> Color {
        isSmall ? color.adjust(brightness: -0.1) : color.adjust(brightness: +0.1)
    }
    
    var cellColor: Color {
        let color = isActivated ?
        colorPalette?.activeColor(pitch: pitch, tonalContext: tonalContext) ?? .clear :
        colorPalette?.inactiveColor(pitch: pitch, tonalContext: tonalContext) ?? .clear
        
        if instrumentalContext.instrumentChoice == .piano &&
            cellType != .tonicPicker &&
            colorPalette?.paletteType == .movable {
            return adjustCellBrightness(color: color)
        } else {
            return color
        }
    }
    
    var textColor: Color {
        isActivated ?
        colorPalette?.activeTextColor(pitch: pitch, tonalContext: tonalContext) ?? .clear :
        colorPalette?.inactiveTextColor(pitch: pitch, tonalContext: tonalContext) ?? .clear
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
        isActivated ?
        colorPalette?.activeOutlineColor(pitch: pitch, tonalContext: tonalContext) ?? .clear :
        colorPalette?.inactiveOutlineColor(pitch: pitch, tonalContext: tonalContext) ?? .clear
//
//        switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
//        case .subtle:
//            return isActivated
//                ? Color(HomeyMusicKit.primaryColor)
//                : pitch.majorMinor(for: tonalContext).color
//        case .loud:
//            return isActivated
//                ? pitch.majorMinor(for: tonalContext).color
//                : Color(HomeyMusicKit.primaryColor)
//        case .ebonyIvory:
//            return Color(MajorMinor.altNeutralColor)
//        }
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
