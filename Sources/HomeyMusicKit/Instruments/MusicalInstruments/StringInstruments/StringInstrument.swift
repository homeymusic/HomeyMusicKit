import Foundation
import SwiftData

public protocol StringInstrument: MusicalInstrument, AnyObject, Observable {
  static var defaultOpenStringsMIDI: [Int] { get }
  
  var openStringsMIDI: [Int] { get }
}

public extension StringInstrument {
  var openStringsMIDI: [Int] {
    Self.defaultOpenStringsMIDI
  }
}
