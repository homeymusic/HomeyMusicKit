import SwiftUI
import SwiftData
import MIDIKitCore

public struct PitchCellPreview: View, CellProtocol {
    let cellType: CellType
    let namedCoordinateSpace: String
    let isActivated: Bool
    let majorMinor: MajorMinor
    let consonanceDissonance: ConsonanceDissonance
    let isNatural: Bool
    let isOutlined: Bool
    let isSmall: Bool
    let isPiano: Bool
    var instrument: Instrument
    
    @Environment(\.modelContext) var modelContext
    
    public init(
        isActivated: Bool,
        majorMinor: MajorMinor,
        consonanceDissonance: ConsonanceDissonance,
        isNatural: Bool,
        isOutlined: Bool = false,
        isSmall: Bool = false,
        isPiano: Bool = false,
        instrument: Instrument
    ) {
        self.isActivated = isActivated
        self.majorMinor = majorMinor
        self.consonanceDissonance = consonanceDissonance
        self.isNatural = isNatural
        self.isOutlined = isOutlined
        self.isSmall = isSmall
        self.cellType = .basic
        self.namedCoordinateSpace = "preview"
        self.isPiano = isPiano
        self.instrument = instrument
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
        isPiano
        ? .top
        : .center
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Color.clear
                .overlay(
                    ZStack(alignment: alignment) {
                        CellPreviewShape(fillColor: .black,
                                  pitchCellPreview: self,
                                  proxySize: proxy.size)
                        .overlay(alignment: alignment) {
                            if isOutlined {
                                CellPreviewShape(fillColor: outlineColor(majorMinor: majorMinor),
                                                 pitchCellPreview: self, proxySize: proxy.size)
                                .frame(
                                    width: proxy.size.width - borderWidthApparentSize,
                                    height: proxy.size.height - borderHeightApparentSize
                                )
                                .overlay(alignment: alignment) {
                                    CellPreviewShape(fillColor: cellColor(majorMinor: majorMinor, isNatural: isNatural), pitchCellPreview: self, proxySize: proxy.size)
                                        .frame(
                                            width: proxy.size.width - outlineWidth,
                                            height: proxy.size.height - outlineHeight
                                        )
                                }
                            } else {
                                CellPreviewShape(fillColor: cellColor(majorMinor: majorMinor, isNatural: isNatural), pitchCellPreview: self, proxySize: proxy.size)
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
                            symbolIcon(proxySize: proxy.size)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(textColor(
                                majorMinor: majorMinor,
                                isNatural: isNatural
                            ))
                        )
                )
        }
    }
    
    // Custom overrides for padding
    func topPadding(_ size: CGSize) -> CGFloat {
        isPiano
        ? relativeCornerRadius(in: size)
        : 0.0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        isPiano
        ? -relativeCornerRadius(in: size)
        : 0.0
    }
    
    var maxOutlineMultiplier: CGFloat {
        isSmall ? 2.0 : 3.0
    }
    
    var outlineMultiplier: CGFloat {
        if consonanceDissonance == .tonic {
            return maxOutlineMultiplier
        } else if cellType == .diamond {
            return maxOutlineMultiplier / 2.0
        } else {
            return maxOutlineMultiplier * 2.0 / 3.0
        }
    }
    
    func symbolIcon(proxySize: CGSize) -> some View {
        AnyView(
            Color.clear.overlay(
                consonanceDissonance.image
                    .resizable()
                    .scaledToFit()
                    .font(Font.system(size: .leastNormalMagnitude,
                                      weight: consonanceDissonance.fontWeight))
                    .frame(maxWidth: consonanceDissonance.imageScale * proxySize.width / (2.0 * HomeyMusicKit.goldenRatio),
                           maxHeight: consonanceDissonance.imageScale * proxySize.height / (2.0 * HomeyMusicKit.goldenRatio))
            )
        )
    }

    
}

struct CellPreviewShape: View {
    var fillColor: Color
    var pitchCellPreview: PitchCellPreview
    var proxySize: CGSize
    
    var body: some View {
        Rectangle()
            .fill(fillColor)
            .padding(.top, pitchCellPreview.topPadding(proxySize))
            .padding(.leading, pitchCellPreview.leadingPadding(proxySize))
            .padding(.trailing, pitchCellPreview.trailingPadding(proxySize))
            .cornerRadius(pitchCellPreview.relativeCornerRadius(in: proxySize))
            .padding(.top, pitchCellPreview.negativeTopPadding(proxySize))
    }
}

