import SwiftUI

public struct ModeLabelsView: View {
    let tonalityInstrument: TonalityInstrument
    var modeCell: ModeCell
    var proxySize: CGSize
    
    public var body: some View {
        Labels(tonalityInstrument: tonalityInstrument, modeCell: modeCell, proxySize: proxySize)
    }
    
    struct Labels: View {
        let tonalityInstrument: TonalityInstrument
        let modeCell: ModeCell
        let proxySize: CGSize
        
        var body: some View {
            mapModeLabel
        }
        
        var mapModeLabel: some View {
            let defaultPadding: CGFloat = 3.0
            return VStack(spacing: 1.0) {
                if tonalityInstrument.pitchLabelTypes.contains(.mode) {
                    overlayText(
                        modeCell.mode.shortHand
                    )
                }
                if tonalityInstrument.pitchLabelTypes.contains(.map) {
                    Color.clear.overlay(
                        HStack(spacing: 1.0) {
                            mapIconImages
                        }
                    )
                }
            }
            .padding(defaultPadding)
            .foregroundColor(modeCell.textColor(
                majorMinor: modeCell.mode.majorMinor,
                isNatural: modeCell.mode.isNatural
            ))
            .minimumScaleFactor(0.1)
            .lineLimit(1)
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
        
        
        func overlayText(_ text: String, font: Font? = nil) -> some View {
#if os(macOS)
            Color.clear.overlay(
                Text(text)
                    .font(font ?? .largeTitle)
            )
#else
            Color.clear.overlay(
                Text(text)
                    .font(font ?? .body)
            )
#endif
        }
        
    }
    
}
