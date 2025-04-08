import SwiftUI
import SwiftData

protocol CellProtocol: View {
    // Helper layout functions
    func minDimension(_ size: CGSize) -> CGFloat
    func relativeFontSize(in containerSize: CGSize) -> CGFloat
    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat
    func topPadding(_ size: CGSize) -> CGFloat
    func leadingPadding(_ size: CGSize) -> CGFloat
    func trailingPadding(_ size: CGSize) -> CGFloat
    func negativeTopPadding(_ size: CGSize) -> CGFloat
    func outlineColor(majorMinor: MajorMinor) -> Color
    func cellColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func textColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    
    // Offsets (if applicable)
    var leadingOffset: CGFloat { get }
    var trailingOffset: CGFloat { get }
    var cellType: CellType { get }
    var namedCoordinateSpace: String { get }
    var isSmall: Bool { get }
    var isActivated: Bool { get }
    var colorPalette: ColorPalette? { get set }
    var instrumentalContext: InstrumentalContext  { get }
    var notationalContext: NotationalContext  { get }
    var modelContext: ModelContext { get }
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
    
    func cellColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        let color = isActivated ?
        colorPalette?.activeColor(majorMinor: majorMinor, isNatural: isNatural) ?? .clear :
        colorPalette?.inactiveColor(isNatural: isNatural) ?? .clear
        
        if instrumentalContext.instrumentChoice == .piano &&
            cellType != .tonicPicker &&
            colorPalette?.paletteType == .interval {
            return adjustCellBrightness(color: color)
        } else {
            return color
        }
    }
    
    func outlineColor(majorMinor: MajorMinor) -> Color {
        isActivated ?
        colorPalette?.activeOutlineColor(majorMinor: majorMinor) ?? .clear :
        colorPalette?.inactiveOutlineColor(majorMinor: majorMinor) ?? .clear
    }
    
    func textColor(majorMinor: MajorMinor, isNatural: Bool) -> Color {
        isActivated ?
        colorPalette?.activeTextColor(majorMinor: majorMinor, isNatural: isNatural) ?? .clear :
        colorPalette?.inactiveTextColor(majorMinor: majorMinor, isNatural: isNatural) ?? .clear
    }

    func topPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func leadingPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func trailingPadding(_ size: CGSize) -> CGFloat { 0.0 }
    func negativeTopPadding(_ size: CGSize) -> CGFloat { 0.0 }
    
    var leadingOffset: CGFloat { 0.0 }
    var trailingOffset: CGFloat { 0.0 }
    
    var isSmall: Bool { false }
    
    func adjustCellBrightness(color: Color) -> Color {
        isSmall ? color.adjust(brightness: -0.1) : color.adjust(brightness: +0.1)
    }    
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
