import SwiftUI

struct TonicRectsKey: PreferenceKey {
    static let defaultValue: [TonicRectInfo] = []

    static func reduce(value: inout [TonicRectInfo], nextValue: () -> [TonicRectInfo]) {
        value.append(contentsOf: nextValue())
    }
}

struct TonicRectInfo: Equatable, Sendable {
    var rect: CGRect
    var midiNoteNumber: MIDINoteNumber
    var zIndex: Int = 0
}
