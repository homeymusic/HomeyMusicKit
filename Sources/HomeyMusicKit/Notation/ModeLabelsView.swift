import SwiftUI

public struct ModeLabelsView: View {
    let tonalityInstrument: TonalityInstrument
    var modeCell: ModeCell
    var proxySize: CGSize

    public var body: some View {
        let topBottomPadding = modeCell.isOutlined ? 0.0 : 0.5 * modeCell.outlineSize
        let extraPadding = topBottomPadding
        VStack(spacing: 0.0) {
            Labels(tonalityInstrument: tonalityInstrument, modeCell: modeCell, proxySize: proxySize)
                .padding([.top, .bottom], extraPadding)
        }
    }
    
    struct Labels: View {
        let tonalityInstrument: TonalityInstrument
        let modeCell: ModeCell
        let proxySize: CGSize
        
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
                    if tonalityInstrument.pitchLabelTypes.contains(.mode) {
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
                    if tonalityInstrument.pitchLabelTypes.contains(.map) {
                        Color.clear.overlay(
                            HStack(spacing: 1.0) {
                                mapIconImages
                            }
                                .padding(2.0)
                                .background(Color(modeCell.cellColor(majorMinor: modeCell.mode.majorMinor, isNatural: modeCell.mode.isNatural)))
                                .cornerRadius(3.0)
                        )
                    }
                }
            )
        }
        
        var mapIconImages: some View {
            Group {
                modeCell.mode.pitchDirection.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(modeCell.textColor(
                        majorMinor: modeCell.mode.pitchDirection.majorMinor,
                        isNatural: modeCell.mode.isNatural
                    ))
                modeCell.mode.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(modeCell.textColor(
                        majorMinor: modeCell.mode.chordShape.majorMinor,
                        isNatural: modeCell.mode.isNatural
                    ))
            }
        }
        
        func minDimension(_ size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
    }
    
}

