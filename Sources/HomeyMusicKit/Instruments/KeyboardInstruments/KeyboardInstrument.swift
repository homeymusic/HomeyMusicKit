import SwiftUI
import MIDIKitIO
import Combine

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
    @Published public var cols: Int  {
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
        
        // Now subscribe to changes. Whenever `rows` or `cols` changes, save to UserDefaults
        $rows
            .sink { [weak self] newRows in
                guard let self = self else { return }
                // clamp to valid range just in case
                let clamped = max(self.minRows, min(self.maxRows, newRows))
                UserDefaults.standard.set(clamped, forKey: self.rowsKey)
            }
            .store(in: &cancellables)
        
        $cols
            .sink { [weak self] newCols in
                guard let self = self else { return }
                // clamp to valid range just in case
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
