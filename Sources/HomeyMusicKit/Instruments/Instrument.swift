import Foundation
import MIDIKitIO

public class Instrument: ObservableObject {
    public let instrumentChoice: InstrumentChoice
    
    @MainActor
    public var colorPalette: ColorPalette

    @MainActor
    public init(
        instrumentChoice: InstrumentChoice,
        colorPalette: ColorPalette = IntervalColorPalette.homey
    ) {
        self.instrumentChoice = instrumentChoice
        self.colorPalette = colorPalette
    }
}
