import Foundation
import CoreGraphics
import SwiftData

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
    /// “Latch” mode on/off
    var latching: Bool { get set }

    var showOutlines: Bool { get set }

}
