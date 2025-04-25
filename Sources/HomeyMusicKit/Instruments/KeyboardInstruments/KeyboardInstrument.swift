import Foundation
import SwiftData

public protocol KeyboardInstrument: Instrument, AnyObject, Observable {
    // MARK: — immutable configuration
    var defaultRows: Int { get }
    var minRows:     Int { get }
    var maxRows:     Int { get }

    var defaultCols: Int { get }
    var minCols:     Int { get }
    var maxCols:     Int { get }

    // MARK: — persisted state
    var rows: Int { get set }
    var cols: Int { get set }

    // MARK: — overridable layout API
    func colIndices(
      forTonic tonic: Int,
      pitchDirection: PitchDirection
    ) -> [Int]

    // MARK: — mutators & availability
    func resetRows()
    var fewerRowsAreAvailable: Bool { get }
    func fewerRows()

    var moreRowsAreAvailable: Bool { get }
    func moreRows()

    func resetCols()
    var fewerColsAreAvailable: Bool { get }
    func fewerCols()

    var moreColsAreAvailable: Bool { get }
    func moreCols()

    // MARK: — combined helpers
    func resetRowsCols()
    var rowColsAreNotDefault: Bool { get }
    var rowIndices: [Int] { get }
}

public extension KeyboardInstrument {
    // MARK: — built-in mutators (with global `buzz()`)
    func resetRows() {
        rows = defaultRows
        buzz()
    }
    var fewerRowsAreAvailable: Bool { rows > minRows }
    func fewerRows() {
        guard fewerRowsAreAvailable else { return }
        rows -= 1
        buzz()
    }
    var moreRowsAreAvailable: Bool { rows < maxRows }
    func moreRows() {
        guard moreRowsAreAvailable else { return }
        rows += 1
        buzz()
    }

    func resetCols() {
        cols = defaultCols
        buzz()
    }
    var fewerColsAreAvailable: Bool { cols > minCols }
    func fewerCols() {
        guard fewerColsAreAvailable else { return }
        cols -= 1
        buzz()
    }
    var moreColsAreAvailable: Bool { cols < maxCols }
    func moreCols() {
        guard moreColsAreAvailable else { return }
        cols += 1
        buzz()
    }

    // MARK: — combined helpers
    func resetRowsCols() {
        resetRows()
        resetCols()
    }
    var rowColsAreNotDefault: Bool {
        rows != defaultRows || cols != defaultCols
    }
    var rowIndices: [Int] {
        Array((-rows...rows).reversed())
    }

    // MARK: — default “tritone-centered” layout
    func colIndices(
      forTonic tonic: Int,
      pitchDirection: PitchDirection
    ) -> [Int] {
        let semis = (pitchDirection == .downward) ? -6 : 6
        let low   = tonic + semis - cols
        let high  = tonic + semis + cols
        return Array(low...high)
    }
}
