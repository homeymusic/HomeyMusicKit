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

    var center: CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }
}

struct PitchRectsKey: PreferenceKey {
    static let defaultValue: [InstrumentCoordinate: PitchRectInfo] = [:]
    
    static func reduce(value: inout [InstrumentCoordinate: PitchRectInfo],
                       nextValue: () -> [InstrumentCoordinate: PitchRectInfo]) {
        
        let newDict = nextValue()
        value.merge(newDict) { oldVal, newVal in
            newVal
        }
    }
}
