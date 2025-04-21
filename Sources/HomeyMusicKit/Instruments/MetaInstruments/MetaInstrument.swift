import Foundation
import MIDIKitIO

public class MetaInstrument: Instrument {
    public let pickerChoice: PickerChoice

    public init(pickerChoice: PickerChoice) {
        super.init()
        self.pickerChoice = pickerChoice
    }
}
