import SwiftUI

/// For accumulating key rects.
struct PitchRectsKey: PreferenceKey {
    static let defaultValue: [PitchRectInfo] = []

    static func reduce(value: inout [PitchRectInfo], nextValue: () -> [PitchRectInfo]) {
        value.append(contentsOf: nextValue())
    }
}

struct PitchRectInfo: Equatable, @unchecked Sendable {
    var rect: CGRect
    var pitch: Pitch
    var zIndex: Int = 0
}
