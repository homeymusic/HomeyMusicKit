import Foundation
import SwiftData

public protocol StringInstrument: Instrument, AnyObject, Observable {
    var openStringsMIDI: [Int] { get }
}
