import SwiftUI

@Observable
public class NotationalContext {
    
    // MARK: - Persistence Key Helper
    /// In the base class the key prefix is empty.
    public var keyPrefix: String { "" }
    
    /// Returns a full key, namespaced by keyPrefix if needed.
    public func key(for base: String) -> String {
        keyPrefix.isEmpty ? base : "\(keyPrefix)_\(base)"
    }
    
    // MARK: - Persisted Properties
    /// Dictionaries mapping each instrument type to its own label state.
    public var noteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        didSet { saveNoteLabels() }
    }
    public var intervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] {
        didSet { saveIntervalLabels() }
    }
    public var colorPaletteName: [InstrumentChoice: String] {
        didSet { saveColorPaletteName() }
    }
    public var outline: [InstrumentChoice: Bool] {
        didSet { saveOutline() }
    }
    
    /// Additional simple booleans.
    public var showLabelsPopover: Bool = false {
        didSet { saveShowLabelsPopover() }
    }
    public var showPalettePopover: Bool = false {
        didSet { saveShowPalettePopover() }
    }
    
    public let outlineLabel: String = "Outline"
    
    /// Default interval labels (all false, except `symbol` is true)
    public let defaultIntervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] = {
        Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentChoice in
            (instrumentChoice, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                (choice, choice == .symbol)
            }))
        })
    }()
    
    public var defaultNoteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentChoice in
            (instrumentChoice, Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) }))
        })
    }
    
    public class func defaultColorPaletteName(for instrumentChoice: InstrumentChoice) -> String {
        return HomeyMusicKit.defaultColorPaletteName
    }
    /// Returns the default outline for an instrument.
    public class func defaultOutline(for instrumentChoice: InstrumentChoice) -> Bool {
        return true
    }
    
    // MARK: - Initialization
    public init() {
        // Provide temporary values so self is available.
        self.noteLabels = [:]
        self.intervalLabels = [:]
        self.colorPaletteName = [:]
        self.outline = [:]
        
        // Load persisted noteLabels.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "noteLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [NoteLabelChoice: Bool]].self, from: data) {
            self.noteLabels = decoded
        } else {
            self.noteLabels = defaultNoteLabels
        }
        
        // Load persisted intervalLabels.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "intervalLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [IntervalLabelChoice: Bool]].self, from: data) {
            self.intervalLabels = decoded
        } else {
            self.intervalLabels = Dictionary(uniqueKeysWithValues: InstrumentChoice.allCases.map { instrumentChoice in
                (instrumentChoice, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                    (choice, choice == .symbol)
                }))
            })
        }
        
        // Load persisted colorPaletteName.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "colorPaletteName")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: String].self, from: data) {
            self.colorPaletteName = decoded
        } else {
            self.colorPaletteName = Dictionary(uniqueKeysWithValues: InstrumentChoice.allInstruments.map { instrumentChoice in
                (instrumentChoice, NotationalContext.defaultColorPaletteName(for: instrumentChoice))
            })
        }
        
        // Load persisted outline.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "outline")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: Bool].self, from: data) {
            self.outline = decoded
        } else {
            self.outline = Dictionary(uniqueKeysWithValues: InstrumentChoice.allInstruments.map { instrumentChoice in
                (instrumentChoice, NotationalContext.defaultOutline(for: instrumentChoice))
            })
        }
        
        // Load persisted booleans.
        self.showLabelsPopover = UserDefaults.standard.object(forKey: self.key(for: "showLabelsPopover")) as? Bool ?? false
        self.showPalettePopover = UserDefaults.standard.object(forKey: self.key(for: "showPalettePopover")) as? Bool ?? false
        
        // Ensure every instrument type has a value.
        InstrumentChoice.allInstruments.forEach { instrumentChoice in
            if self.noteLabels[instrumentChoice] == nil {
                self.noteLabels[instrumentChoice] = defaultNoteLabels[instrumentChoice]
            }
            if self.intervalLabels[instrumentChoice] == nil {
                self.intervalLabels[instrumentChoice] = defaultIntervalLabels[instrumentChoice]
            }
            if self.colorPaletteName[instrumentChoice] == nil {
                self.colorPaletteName[instrumentChoice] = NotationalContext.defaultColorPaletteName(for: instrumentChoice)
            }
            if self.outline[instrumentChoice] == nil {
                self.outline[instrumentChoice] = NotationalContext.defaultOutline(for: instrumentChoice)
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
    
    public func saveColorPaletteName() {
        if let encoded = try? JSONEncoder().encode(colorPaletteName) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "colorPaletteName"))
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
    public func areLabelsDefault(for instrumentChoice: InstrumentChoice) -> Bool {
        guard let currentNoteLabels = noteLabels[instrumentChoice],
              let currentIntervalLabels = intervalLabels[instrumentChoice] else {
            return false
        }
        return currentNoteLabels == defaultNoteLabels[instrumentChoice]! &&
        currentIntervalLabels == defaultIntervalLabels[instrumentChoice]!
    }
    
    public func resetLabels(for instrumentChoice: InstrumentChoice) {
        noteLabels[instrumentChoice] = defaultNoteLabels[instrumentChoice]
        intervalLabels[instrumentChoice] = defaultIntervalLabels[instrumentChoice]
        buzz()
    }
    
    public func isColorPaletteNameDefault(for instrumentChoice: InstrumentChoice) -> Bool {
        return self.colorPaletteName[instrumentChoice] == NotationalContext.defaultColorPaletteName(for: instrumentChoice) &&
        self.outline[instrumentChoice] == NotationalContext.defaultOutline(for: instrumentChoice)
    }
    
    public func resetColorPaletteName(for instrumentChoice: InstrumentChoice) {
        self.colorPaletteName[instrumentChoice] = NotationalContext.defaultColorPaletteName(for: instrumentChoice)
        self.outline[instrumentChoice] = NotationalContext.defaultOutline(for: instrumentChoice)
        buzz()
    }
    
    public func noteBinding(for instrumentChoice: InstrumentChoice, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrumentChoice]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrumentChoice]?[choice] = newValue
                self.saveNoteLabels()
            }
        )
    }
    
    public func intervalBinding(for instrumentChoice: InstrumentChoice, choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[instrumentChoice]?[choice] ?? false },
            set: { newValue in
                self.intervalLabels[instrumentChoice]?[choice] = newValue
                self.saveIntervalLabels()
            }
        )
    }
    
    public func colorPaletteNameBinding(for instrumentChoice: InstrumentChoice) -> Binding<String> {
        Binding(
            get: { self.colorPaletteName[instrumentChoice] ?? HomeyMusicKit.defaultColorPaletteName },
            set: { newValue in
                self.colorPaletteName[instrumentChoice] = newValue
                self.saveColorPaletteName()
            }
        )
    }
    public func outlineBinding(for instrumentChoice: InstrumentChoice) -> Binding<Bool> {
        Binding(
            get: { self.outline[instrumentChoice] ?? false },
            set: { newValue in
                self.outline[instrumentChoice] = newValue
                self.saveOutline()
            }
        )
    }
    
}
