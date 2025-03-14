import SwiftUI

struct ModeRectsKey: PreferenceKey {
    static let defaultValue: [ModeRectInfo] = []

    static func reduce(value: inout [ModeRectInfo], nextValue: () -> [ModeRectInfo]) {
        value.append(contentsOf: nextValue())
    }
}

struct ModeRectInfo: Equatable {
    var rect: CGRect
    var mode: Mode
}
