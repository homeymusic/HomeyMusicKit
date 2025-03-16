import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    
    // MARK: - Persistence Key Helper
    /// In the base class the key prefix is empty.
    public var keyPrefix: String { "" }
    
    /// Returns a full key, namespaced by keyPrefix if needed.
    public func key(for base: String) -> String {
        keyPrefix.isEmpty ? base : "\(keyPrefix)_\(base)"
    }
    
    // MARK: - Persisted Properties
    /// Dictionaries mapping each instrument type to its own label state.
    @Published public var noteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        didSet { saveNoteLabels() }
    }
    @Published public var intervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] {
        didSet { saveIntervalLabels() }
    }
    @Published public var colorPalette: [InstrumentChoice: ColorPaletteChoice] {
        didSet { saveColorPalette() }
    }
    @Published public var outline: [InstrumentChoice: Bool] {
        didSet { saveOutline() }
    }
    
    /// Additional simple booleans.
    @Published public var showLabelsPopover: Bool = false {
        didSet { saveShowLabelsPopover() }
    }
    @Published public var showPalettePopover: Bool = false {
        didSet { saveShowPalettePopover() }
    }
    
    public let outlineLabel: String = "Outline"
    
    /// Default interval labels (all false, except `symbol` is true)
    public let defaultIntervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] = {
        Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentType in
            (instrumentType, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                (choice, choice == .symbol)
            }))
        })
    }()
    
    /// Returns the default note labels (all false).
    public class func defaultNoteLabels() -> [InstrumentChoice: [NoteLabelChoice: Bool]] {
        Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentType in
            (instrumentType, Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) }))
        })
    }
    
    /// Returns the default color palette for an instrument.
    public class func defaultColorPalette(for instrumentType: InstrumentChoice) -> ColorPaletteChoice {
        return .subtle
    }
    
    /// Returns the default outline for an instrument.
    public class func defaultOutline(for instrumentType: InstrumentChoice) -> Bool {
        return true
    }
    
    // MARK: - Initialization
    public init() {
        // Provide temporary values so self is available.
        self.noteLabels = [:]
        self.intervalLabels = [:]
        self.colorPalette = [:]
        self.outline = [:]
        
        // Load persisted noteLabels.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "noteLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [NoteLabelChoice: Bool]].self, from: data) {
            self.noteLabels = decoded
        } else {
            self.noteLabels = NotationalContext.defaultNoteLabels()
        }
        
        // Load persisted intervalLabels.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "intervalLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [IntervalLabelChoice: Bool]].self, from: data) {
            self.intervalLabels = decoded
        } else {
            self.intervalLabels = Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentType in
                (instrumentType, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                    (choice, choice == .symbol)
                }))
            })
        }
        
        // Load persisted colorPalette.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "colorPalette")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: ColorPaletteChoice].self, from: data) {
            self.colorPalette = decoded
        } else {
            self.colorPalette = Dictionary(uniqueKeysWithValues: InstrumentChoice.allInstrumentTypes.map { instrumentType in
                (instrumentType, NotationalContext.defaultColorPalette(for: instrumentType))
            })
        }
        
        // Load persisted outline.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "outline")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: Bool].self, from: data) {
            self.outline = decoded
        } else {
            self.outline = Dictionary(uniqueKeysWithValues: InstrumentChoice.allInstrumentTypes.map { instrumentType in
                (instrumentType, NotationalContext.defaultOutline(for: instrumentType))
            })
        }
        
        // Load persisted booleans.
        self.showLabelsPopover = UserDefaults.standard.object(forKey: self.key(for: "showLabelsPopover")) as? Bool ?? false
        self.showPalettePopover = UserDefaults.standard.object(forKey: self.key(for: "showPalettePopover")) as? Bool ?? false
        
        // Ensure every instrument type has a value.
        InstrumentChoice.allInstrumentTypes.forEach { instrumentType in
            if self.noteLabels[instrumentType] == nil {
                self.noteLabels[instrumentType] = NotationalContext.defaultNoteLabels()[instrumentType]
            }
            if self.intervalLabels[instrumentType] == nil {
                self.intervalLabels[instrumentType] = defaultIntervalLabels[instrumentType]
            }
            if self.colorPalette[instrumentType] == nil {
                self.colorPalette[instrumentType] = NotationalContext.defaultColorPalette(for: instrumentType)
            }
            if self.outline[instrumentType] == nil {
                self.outline[instrumentType] = NotationalContext.defaultOutline(for: instrumentType)
            }
        }
    }
    
    // MARK: - Saving Methods
    public func saveNoteLabels() {
        if let encoded = try? JSONEncoder().encode(noteLabels) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "noteLabels"))
        }
    }
    
    public func saveIntervalLabels() {
        if let encoded = try? JSONEncoder().encode(intervalLabels) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "intervalLabels"))
        }
    }
    
    public func saveColorPalette() {
        if let encoded = try? JSONEncoder().encode(colorPalette) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "colorPalette"))
        }
    }
    
    public func saveOutline() {
        if let encoded = try? JSONEncoder().encode(outline) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "outline"))
        }
    }
    
    public func saveShowLabelsPopover() {
        UserDefaults.standard.set(showLabelsPopover, forKey: self.key(for: "showLabelsPopover"))
    }
    
    public func saveShowPalettePopover() {
        UserDefaults.standard.set(showPalettePopover, forKey: self.key(for: "showPalettePopover"))
    }
    
    // MARK: - Utility Methods (Unchanged)
    public func areLabelsDefault(for instrumentType: InstrumentChoice) -> Bool {
        guard let currentNoteLabels = noteLabels[instrumentType],
              let currentIntervalLabels = intervalLabels[instrumentType] else {
            return false
        }
        return currentNoteLabels == NotationalContext.defaultNoteLabels()[instrumentType]! &&
        currentIntervalLabels == defaultIntervalLabels[instrumentType]!
    }
    
    public func resetLabels(for instrumentType: InstrumentChoice) {
        noteLabels[instrumentType] = NotationalContext.defaultNoteLabels()[instrumentType]
        intervalLabels[instrumentType] = defaultIntervalLabels[instrumentType]
    }
    
    public func isColorPaletteDefault(for instrumentType: InstrumentChoice) -> Bool {
        return self.colorPalette[instrumentType] == NotationalContext.defaultColorPalette(for: instrumentType) &&
        self.outline[instrumentType] == NotationalContext.defaultOutline(for: instrumentType)
    }
    
    public func resetColorPalette(for instrumentType: InstrumentChoice) {
        self.colorPalette[instrumentType] = NotationalContext.defaultColorPalette(for: instrumentType)
        self.outline[instrumentType] = NotationalContext.defaultOutline(for: instrumentType)
    }
    
    public func noteBinding(for instrumentType: InstrumentChoice, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrumentType]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrumentType]?[choice] = newValue
                self.saveNoteLabels()
            }
        )
    }
    
    public func intervalBinding(for instrumentType: InstrumentChoice, choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[instrumentType]?[choice] ?? false },
            set: { newValue in
                self.intervalLabels[instrumentType]?[choice] = newValue
                self.saveIntervalLabels()
            }
        )
    }
    
    public func colorPaletteBinding(for instrumentType: InstrumentChoice) -> Binding<ColorPaletteChoice> {
        Binding(
            get: { self.colorPalette[instrumentType] ?? .subtle },
            set: { newValue in
                self.colorPalette[instrumentType] = newValue
                self.saveColorPalette()
            }
        )
    }
    
    public func outlineBinding(for instrumentType: InstrumentChoice) -> Binding<Bool> {
        Binding(
            get: { self.outline[instrumentType] ?? false },
            set: { newValue in
                self.outline[instrumentType] = newValue
                self.saveOutline()
            }
        )
    }
    
}
