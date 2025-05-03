import Foundation
import SwiftData

public protocol StringInstrument: MusicalInstrument, AnyObject, Observable {
    var openStringsMIDI: [Int] { get }
}
