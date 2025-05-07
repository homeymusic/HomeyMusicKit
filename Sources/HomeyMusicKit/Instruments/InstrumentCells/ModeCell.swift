import SwiftUI
import SwiftData

public struct ModeCell: View, CellProtocol {
    let instrument: any Instrument
    let mode: Mode
    let row: Int
    let col: Int
    let cellType: CellType
    let namedCoordinateSpace: String

    @Environment(\.modelContext) var modelContext

    public init(
        instrument: Instrument,
        mode: Mode,
        row: Int,
        col: Int,
        cellType: CellType = .basic,
        namedCoordinateSpace: String = HomeyMusicKit.modePickerSpace
    ) {
        self.instrument = instrument as! TonalityInstrument
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
                                    cellType: .basic
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
                                                    .overlay(ModeLabelsView(tonalityInstrument: instrument as! TonalityInstrument, modeCell: self, proxySize: proxy.size)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity))
                                            }
                                    } else {
                                        ModeRectangle(fillColor: cellColor(majorMinor: mode.majorMinor, isNatural: mode.isNatural), modeView: self, proxySize: proxy.size)
                                            .frame(width: proxy.size.width - borderSize, height: proxy.size.height - borderSize)
                                            .overlay(ModeLabelsView(tonalityInstrument: instrument as! TonalityInstrument, modeCell: self, proxySize: proxy.size)
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
        if (instrument.pitchDirection == .upward && col == 0) ||
            (instrument.pitchDirection == .downward && col == 12) {
            return 3.0
        } else {
            return 2.0
        }
    }
    
    var borderSize: CGFloat { 3.0 }
        
    var isOutlined: Bool {
        instrument.showOutlines &&
        (
            mode == instrument.mode ||
            (
                instrument.mode.intervalClasses.contains { $0.rawValue ==  modulo(mode.rawValue - instrument.mode.rawValue, 12)})
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
