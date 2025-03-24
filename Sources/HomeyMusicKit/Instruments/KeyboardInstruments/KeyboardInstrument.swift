import SwiftUI
import MIDIKitIO
import Combine

#if canImport(UIKit)
import UIKit
#endif

public class KeyboardInstrument: Instrument {
    // Layout configuration properties (immutable)
    public let defaultRows: Int
    public let minRows: Int
    public let maxRows: Int

    public let defaultCols: Int
    public let minCols: Int
    public let maxCols: Int

    // State properties to track current layout.
    @Published public var rows: Int {
        didSet {
            buzz()
        }
    }
    @Published public var cols: Int {
        didSet {
            buzz()
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var rowsKey: String { "rows_" + String(instrumentChoice.rawValue) }
    private var colsKey: String { "cols_" + String(instrumentChoice.rawValue) }

    public init(instrumentChoice: InstrumentChoice,
                defaultRows: Int,
                minRows: Int,
                maxRows: Int,
                defaultCols: Int,
                minCols: Int,
                maxCols: Int) {

        self.defaultRows = defaultRows
        self.minRows = minRows
        self.maxRows = maxRows

        self.defaultCols = defaultCols
        self.minCols = minCols
        self.maxCols = maxCols

        self.rows = defaultRows
        self.cols = defaultCols

        super.init(instrumentChoice: instrumentChoice)

        // Load previously saved rows/cols if they exist
        if let savedRows = UserDefaults.standard.object(forKey: rowsKey) as? Int {
            self.rows = max(minRows, min(maxRows, savedRows))
        }
        if let savedCols = UserDefaults.standard.object(forKey: colsKey) as? Int {
            self.cols = max(minCols, min(maxCols, savedCols))
        }

        // Subscribe to changes. Whenever `rows` or `cols` changes, save to UserDefaults.
        $rows
            .sink { [weak self] newRows in
                guard let self = self else { return }
                let clamped = max(self.minRows, min(self.maxRows, newRows))
                UserDefaults.standard.set(clamped, forKey: self.rowsKey)
            }
            .store(in: &cancellables)

        $cols
            .sink { [weak self] newCols in
                guard let self = self else { return }
                let clamped = max(self.minCols, min(self.maxCols, newCols))
                UserDefaults.standard.set(clamped, forKey: self.colsKey)
            }
            .store(in: &cancellables)
    }

    // MARK: - Row Methods

    public func resetRows() {
        rows = defaultRows
    }

    public var fewerRowsAreAvailable: Bool {
        rows > minRows
    }

    public func fewerRows() {
        if fewerRowsAreAvailable {
            rows -= 1
        }
    }

    public var moreRowsAreAvailable: Bool {
        rows < maxRows
    }

    public func moreRows() {
        if moreRowsAreAvailable {
            rows += 1
        }
    }

    // MARK: - Column Methods

    public func resetCols() {
        cols = defaultCols
    }

    public var fewerColsAreAvailable: Bool {
        cols > minCols
    }

    public func fewerCols() {
        if fewerColsAreAvailable {
            cols -= 1
        }
    }

    public var moreColsAreAvailable: Bool {
        cols < maxCols
    }

    public func moreCols() {
        if moreColsAreAvailable {
            cols += 1
        }
    }

    // MARK: - Combined Reset

    public func resetRowsCols() {
        resetRows()
        resetCols()
    }

    public var rowColsAreNotDefault: Bool {
        cols != defaultCols || rows != defaultRows
    }

    public var rowIndices: [Int] {
        Array((-rows ... rows).reversed())
    }

    public func colIndices(forTonic tonic: Int, pitchDirection: PitchDirection) -> [Int] {
        let tritoneSemitones = (pitchDirection == .downward) ? -6 : 6
        let colsBelow = tonic + tritoneSemitones - cols
        let colsAbove = tonic + tritoneSemitones + cols
        return Array(colsBelow...colsAbove)
    }
}

public extension KeyboardInstrument {
    /// Convenience initializer that selects configuration based on platform.
    /// - Parameters:
    ///   - instrumentChoice: The instrument choice identifier.
    ///   - phoneRows: Row configuration for iPhone.
    ///   - phoneCols: Column configuration for iPhone.
    ///   - padRows: Row configuration for iPad.
    ///   - padCols: Column configuration for iPad.
    ///   - computerRows: Row configuration for computer platforms (e.g. macOS).
    ///   - computerCols: Column configuration for computer platforms (e.g. macOS).
    @MainActor
    convenience init(instrumentChoice: InstrumentChoice,
                     phoneRows: (default: Int, min: Int, max: Int),
                     phoneCols: (default: Int, min: Int, max: Int),
                     padRows: (default: Int, min: Int, max: Int),
                     padCols: (default: Int, min: Int, max: Int),
                     computerRows: (default: Int, min: Int, max: Int),
                     computerCols: (default: Int, min: Int, max: Int)) {
        #if os(iOS) || os(tvOS)
        let config: (rows: (default: Int, min: Int, max: Int),
                     cols: (default: Int, min: Int, max: Int))
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            config = (rows: phoneRows, cols: phoneCols)
        case .pad:
            config = (rows: padRows, cols: padCols)
        default:
            fatalError("Unsupported device idiom")
        }
        #elseif os(macOS)
        let config = (rows: computerRows, cols: computerCols)
        #else
        fatalError("Unsupported platform")
        #endif

        self.init(instrumentChoice: instrumentChoice,
                  defaultRows: config.rows.default,
                  minRows: config.rows.min,
                  maxRows: config.rows.max,
                  defaultCols: config.cols.default,
                  minCols: config.cols.min,
                  maxCols: config.cols.max)
    }
}
