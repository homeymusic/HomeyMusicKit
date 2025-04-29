// KeyboardInstrument.swift

import Foundation
import SwiftData

public protocol KeyboardInstrument: Instrument, AnyObject, Observable {
    // MARK: — config tuples instead of six separate statics + computed props
    static var rowConfig: (default: Int, min: Int, max: Int) { get }
    static var colConfig: (default: Int, min: Int, max: Int) { get }

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
    var rowColsAreDefault: Bool { get }
    var rowIndices: [Int] { get }
}

public extension KeyboardInstrument {
    func resetRows() {
        rows = Self.rowConfig.default
    }
    var fewerRowsAreAvailable: Bool { rows > Self.rowConfig.min }
    func fewerRows() {
        guard fewerRowsAreAvailable else { return }
        rows -= 1
    }
    var moreRowsAreAvailable: Bool { rows < Self.rowConfig.max }
    func moreRows() {
        guard moreRowsAreAvailable else { return }
        rows += 1
    }

    func resetCols() {
        cols = Self.colConfig.default
    }
    var fewerColsAreAvailable: Bool { cols > Self.colConfig.min }
    func fewerCols() {
        guard fewerColsAreAvailable else { return }
        cols -= 1
    }
    var moreColsAreAvailable: Bool { cols < Self.colConfig.max }
    func moreCols() {
        guard moreColsAreAvailable else { return }
        cols += 1
    }

    // MARK: — combined helpers
    func resetRowsCols() {
        resetRows()
        resetCols()
    }
    var rowColsAreDefault: Bool {
        rows == Self.rowConfig.default && cols == Self.colConfig.default
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
