import SwiftUI

/// Make this public so protocols/end‐users can refer to it.
public struct InstrumentCoordinate: Hashable, Sendable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

/// Likewise, expose the cell itself.
public struct OverlayCell: Equatable, Sendable {
    public var rect: CGRect
    public var identifier: Int
    public var zIndex: Int = 0
    public var layoutOffset: Bool = false
    public var cellType: CellType

    public init(
        rect: CGRect,
        identifier: Int,
        zIndex: Int = 0,
        layoutOffset: Bool = false,
        cellType: CellType
    ) {
        self.rect          = rect
        self.identifier    = identifier
        self.zIndex        = zIndex
        self.layoutOffset  = layoutOffset
        self.cellType      = cellType
    }

    public var center: CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }

    public func contains(_ point: CGPoint) -> Bool {
        switch cellType {
        case .diamond:
            let halfSize = rect.width / 2
            let dx = abs(point.x - rect.midX)
            let dy = abs(point.y - rect.midY)
            return (dx + dy) <= halfSize
        default:
            return rect.contains(point)
        }
    }
}

/// And finally, the PreferenceKey must be public too.
public struct OverlayCellKey: PreferenceKey {
    public static let defaultValue: [InstrumentCoordinate: OverlayCell] = [:]

    public static func reduce(
        value: inout [InstrumentCoordinate: OverlayCell],
        nextValue: () -> [InstrumentCoordinate: OverlayCell]
    ) {
        let newDict = nextValue()
        let overlap = Set(value.keys).intersection(newDict.keys)
        if !overlap.isEmpty {
            fatalError("Collision detected for the following (row,col) keys: \(overlap)")
        }
        value.merge(newDict) { _, new in new }
    }
}
