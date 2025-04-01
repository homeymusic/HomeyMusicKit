import SwiftUI

struct InstrumentCoordinate: Hashable {
    let row: Int
    let col: Int
}

struct PitchRectInfo: Equatable, Sendable {
    var rect: CGRect
    var midiNoteNumber: MIDINoteNumber
    var zIndex: Int = 0
    var layoutOffset: Bool = false
    var containerType: ContainerType
    
    var center: CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }
    
    func contains(_ point: CGPoint) -> Bool {
        switch containerType {
        case .diamond:
            let halfSize = rect.width / 2
            let dx = abs(point.x - rect.midX)
            let dy = abs(point.y - rect.midY)
            return (dx + dy) <= halfSize
        default:
            // For non-diamond container types, use the standard rect.contains
            return rect.contains(point)
        }
    }
    
}

struct PitchRectsKey: PreferenceKey {
    static let defaultValue: [InstrumentCoordinate: PitchRectInfo] = [:]

    static func reduce(value: inout [InstrumentCoordinate: PitchRectInfo],
                       nextValue: () -> [InstrumentCoordinate: PitchRectInfo]) {
        let newDict = nextValue()

        // Find any intersection of keys (row,col) that exist in both dictionaries
        let overlap = Set(value.keys).intersection(newDict.keys)
        if !overlap.isEmpty {
            fatalError("Collision detected for the following (row,col) keys: \(overlap)")
        }

        // If there’s no overlap, just merge
        value.merge(newDict) { _, new in new }
    }
}
