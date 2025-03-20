import SwiftUI

/// For accumulating key rects.
struct PitchRectsKey: PreferenceKey {
    static let defaultValue: [PitchRectInfo] = []

    static func reduce(value: inout [PitchRectInfo], nextValue: () -> [PitchRectInfo]) {
        value.append(contentsOf: nextValue())
    }
}

struct PitchRectInfo: Equatable, Sendable {
    var rect: CGRect
    var midiNoteNumber: MIDINoteNumber
    var zIndex: Int = 0
}
