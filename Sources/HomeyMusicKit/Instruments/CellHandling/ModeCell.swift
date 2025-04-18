import SwiftUI
import SwiftData

public struct ModeCell: View, CellProtocol {
    
    let mode: Mode
    let row: Int
    let col: Int
    let cellType: CellType
    let namedCoordinateSpace: String
    
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    @Environment(NotationalTonicContext.self) var notationalTonicContext
    @Environment(\.modelContext) var modelContext

    public init(
        mode: Mode,
        row: Int,
        col: Int,
        cellType: CellType = .modePicker,
        namedCoordinateSpace: String = HomeyMusicKit.modePickerSpace
    ) {
        self.mode = mode
        self.row = row
        self.col = col
        self.cellType = cellType
        self.namedCoordinateSpace = namedCoordinateSpace
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named(namedCoordinateSpace))
            Color.clear
                .preference(key: OverlayCellKey.self,
                            value: [
                                InstrumentCoordinate(row: row, col: col): OverlayCell(
                                    rect: rect,
                                    identifier: Int(mode.rawValue),
                                    cellType: .modePicker
                                )
                            ])
                .overlay(
                    ZStack(alignment: .center) {
                        ZStack(alignment: .center) {
                            ModeRectangle(fillColor: .black, modeView: self, proxySize: proxy.size)
                                .overlay(alignment: .center) {
                                    if isOutlined {
                                        ModeRectangle(fillColor: outlineColor(majorMinor: mode.majorMinor), modeView: self, proxySize: proxy.size)
                                            .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                            .overlay(alignment: .center) {
                                                ModeRectangle(fillColor: cellColor(majorMinor: mode.majorMinor, isNatural: mode.isNatural), modeView: self, proxySize: proxy.size)
                                                    .frame(width: proxy.size.width - outlineSize, height: proxy.size.height - outlineSize)
                                                    .overlay(ModeLabelView(modeCell: self, proxySize: proxy.size)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity))
                                            }
                                    } else {
                                        ModeRectangle(fillColor: cellColor(majorMinor: mode.majorMinor, isNatural: mode.isNatural), modeView: self, proxySize: proxy.size)
                                            .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                            .overlay(ModeLabelView(modeCell: self, proxySize: proxy.size)
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
    
    var isActivated: Bool { false }
    
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
        
    var isOutlined: Bool {
        notationalContext.outline[instrumentalContext.instrumentChoice]! &&
        (
            mode == tonalContext.mode ||
            (notationalTonicContext.showTonicPicker &&
             tonalContext.mode.intervalClasses.contains { $0.rawValue ==  modulo(mode.rawValue - tonalContext.mode.rawValue, 12)})
        )
    }
        
}
struct ModeRectangle: View {
    var fillColor: Color
    var modeView: ModeCell
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
