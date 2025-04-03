import SwiftUI

struct CellShape: View {
    var fillColor: Color
    var pitchCell: PitchCell
    var proxySize: CGSize
    
    var body: some View {
        if pitchCell.cellType == .tonnetz {
            Circle()
                .fill(fillColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            Rectangle()
                .fill(fillColor)
                .padding(.top, pitchCell.topPadding(proxySize))
                .padding(.leading, pitchCell.leadingPadding(proxySize))
                .padding(.trailing, pitchCell.trailingPadding(proxySize))
                .cornerRadius(pitchCell.relativeCornerRadius(in: proxySize))
                .padding(.top, pitchCell.negativeTopPadding(proxySize))
        }
    }
}
