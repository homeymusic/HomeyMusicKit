import SwiftUI

protocol CellProtocol: View {
    // Helper layout functions
    func minDimension(_ size: CGSize) -> CGFloat
    func relativeFontSize(in containerSize: CGSize) -> CGFloat
    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat
    func topPadding(_ size: CGSize) -> CGFloat
    func leadingPadding(_ size: CGSize) -> CGFloat
    func trailingPadding(_ size: CGSize) -> CGFloat
    func negativeTopPadding(_ size: CGSize) -> CGFloat

    // Offsets (if applicable)
    var leadingOffset: CGFloat { get }
    var trailingOffset: CGFloat { get }
    var cellType: CellType { get }
    var namedCoordinateSpace: String { get }
    var isSmall: Bool { get }
    var isActivated: Bool { get }
    var colorPalette: ColorPalette? { get }

}

extension CellProtocol {
    func minDimension(_ size: CGSize) -> CGFloat {
        min(size.width, size.height)
    }
    
    func relativeFontSize(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.333
    }
    
    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.125
    }
    
    func outlineColor(majorMinor: MajorMinor) -> Color {
        isActivated ?
        colorPalette?.activeOutlineColor(majorMinor: majorMinor) ?? .clear :
        colorPalette?.inactiveOutlineColor(majorMinor: majorMinor) ?? .clear
    }


    func topPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func leadingPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func trailingPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func negativeTopPadding(_ size: CGSize) -> CGFloat { 0.0 }
    
    var leadingOffset: CGFloat { 0.0 }
    var trailingOffset: CGFloat { 0.0 }
    
    var isSmall: Bool { false }

}

public enum CellType: Sendable {
    case basic
    case diamond
    case span
    case tonicPicker
    case modePicker
    case tonnetz
    case swapNotation
    case piano
}
