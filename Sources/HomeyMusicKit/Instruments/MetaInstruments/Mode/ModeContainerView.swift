import SwiftUI

/// This handles the interaction for a mode so the user can provide their own visual representation.
public struct ModeContainerView: View {
    // Update the closure type to accept a Mode and a columnIndex.
    var mode: Mode
    var columnIndex: Int  // Pass the column position from ModePickerView.
    var modeView: ModeView
    var row: Int
    var col: Int
    
    init(mode: Mode,
         columnIndex: Int,
         row: Int,
         col: Int
    )
    {
        self.mode = mode
        self.columnIndex = columnIndex
        self.modeView = ModeView(mode: mode,  columnIndex: columnIndex)
        self.row = row
        self.col = col
    }
    
    func rect(rect: CGRect) -> some View {
        // Pass both the mode and the columnIndex to the modeView closure.
        modeView
            .preference(key: OverlayCellKey.self,
                        value: [
                            InstrumentCoordinate(row: row, col: col): OverlayCell(
                                rect: rect,
                                identifier: Int(mode.rawValue),
                                containerType: .modePicker
                        )])
    }
    
    public var body: some View {
        GeometryReader { proxy in
            rect(rect: proxy.frame(in: .named(HomeyMusicKit.modePickerSpace)))
        }
    }
}
