import SwiftUI
import SwiftData

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
    
    public var colorPalettes: [InstrumentChoice: ColorPalette]
    
    // Private dictionary that holds UUIDs for persistence.
    private var colorPaletteIDs: [InstrumentChoice: UUID] = [:]


    @MainActor
    public func colorPalette(for instrumentChoice: InstrumentChoice) -> ColorPalette {
        colorPalettes[instrumentChoice] ?? IntervalColorPalette.homey
    }
    
    public var outline: [InstrumentChoice: Bool] {
        didSet { saveOutline() }
    }
    
    /// Additional simple booleans.
    public var showLabelsPopover: Bool = false
    public var showColorPalettePopover: Bool = false
    public var showEditColorPaletteSheet: Bool = false
    
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
    
    @MainActor
    public class func defaultColorPalette(for instrumentChoice: InstrumentChoice) -> IntervalColorPalette {
        return IntervalColorPalette.homey
    }
    /// Returns the default outline for an instrument.
    public class func defaultOutline(for instrumentChoice: InstrumentChoice) -> Bool {
        return true
    }
    
    // MARK: - Initialization
    @MainActor
    public init() {
        // Provide temporary values so self is available.
        self.noteLabels = [:]
        self.intervalLabels = [:]
        self.outline = [:]
        self.colorPalettes = [:]
        
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
        
        // Load persisted outline.
        if let data = UserDefaults.standard.data(forKey: self.key(for: "outline")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: Bool].self, from: data) {
            self.outline = decoded
        } else {
            self.outline = Dictionary(uniqueKeysWithValues: InstrumentChoice.allInstruments.map { instrumentChoice in
                (instrumentChoice, NotationalContext.defaultOutline(for: instrumentChoice))
            })
        }
        
        if let data = UserDefaults.standard.data(forKey: self.key(for: "colorPaletteIDs")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: UUID].self, from: data) {
            self.colorPaletteIDs = decoded
        }
        
        // Load persisted booleans.
        self.showLabelsPopover = UserDefaults.standard.object(forKey: self.key(for: "showLabelsPopover")) as? Bool ?? false
        self.showColorPalettePopover = UserDefaults.standard.object(forKey: self.key(for: "showPalettePopover")) as? Bool ?? false
        self.showEditColorPaletteSheet = UserDefaults.standard.object(forKey: self.key(for: "showEditColorPaletteSheet")) as? Bool ?? false

        // Ensure every instrument type has a value.
        InstrumentChoice.allInstruments.forEach { instrumentChoice in
            if self.noteLabels[instrumentChoice] == nil {
                self.noteLabels[instrumentChoice] = defaultNoteLabels[instrumentChoice]
            }
            if self.intervalLabels[instrumentChoice] == nil {
                self.intervalLabels[instrumentChoice] = defaultIntervalLabels[instrumentChoice]
            }
            if self.outline[instrumentChoice] == nil {
                self.outline[instrumentChoice] = NotationalContext.defaultOutline(for: instrumentChoice)
            }
            if self.colorPalettes[instrumentChoice] == nil {
                self.colorPalettes[instrumentChoice] = IntervalColorPalette.homey
            }

        }
    }
    
    @MainActor
    private func fetchColorPalette(with id: UUID, from context: ModelContext) -> ColorPalette? {
        // If you have multiple palette types (PitchColorPalette & IntervalColorPalette),
        // you'll need to do 1 or 2 fetches. For example:
        let pitchDescriptor = FetchDescriptor<PitchColorPalette>(
            predicate: #Predicate { $0.id == id }
        )
        if let found = try? context.fetch(pitchDescriptor).first {
            return found
        }
        
        let intervalDescriptor = FetchDescriptor<IntervalColorPalette>(
            predicate: #Predicate { $0.id == id }
        )
        if let found = try? context.fetch(intervalDescriptor).first {
            return found
        }
        
        return nil
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
    
    public func saveOutline() {
        if let encoded = try? JSONEncoder().encode(outline) {
            UserDefaults.standard.set(encoded, forKey: self.key(for: "outline"))
        }
    }
        
    @MainActor
    public func loadColorPaletteIDs(modelContext: ModelContext) {
        for instrumentChoice in InstrumentChoice.allInstruments {
            // If we have a stored UUID, try to fetch the real palette from SwiftData
            if let storedID = colorPaletteIDs[instrumentChoice] {
                if let fetchedPalette = fetchColorPalette(with: storedID, from: modelContext) {
                    colorPalettes[instrumentChoice] = fetchedPalette
                } else {
                    // If fetch fails or no object found, fall back to a default
                    colorPalettes[instrumentChoice] = IntervalColorPalette.homey
                }
            } else {
                // If we have no storedID, also fall back to default
                colorPalettes[instrumentChoice] = IntervalColorPalette.homey
            }
        }
    }
    
    public func saveColorPaletteIDs() {
        guard let data = try? JSONEncoder().encode(colorPaletteIDs) else { return }
        UserDefaults.standard.set(data, forKey: self.key(for: "colorPaletteIDs"))
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
    
    @MainActor
    public func isColorPaletteDefault(for instrumentChoice: InstrumentChoice) -> Bool {
        return self.colorPalette(for: instrumentChoice).name == IntervalColorPalette.homey.name &&
        self.outline[instrumentChoice] == NotationalContext.defaultOutline(for: instrumentChoice)
    }
    
    @MainActor
    public func resetColorPalette(for instrumentChoice: InstrumentChoice) {
        let paletteBinding = colorPaletteBinding(for: instrumentChoice)
        paletteBinding.wrappedValue = IntervalColorPalette.homey
        self.outline[instrumentChoice] = NotationalContext.defaultOutline(for: instrumentChoice)
        buzz()
    }
    
    @MainActor
    public func noteBinding(for instrumentChoice: InstrumentChoice, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrumentChoice]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrumentChoice]?[choice] = newValue
                self.saveNoteLabels()
            }
        )
    }
    
    @MainActor
    public func intervalBinding(for instrumentChoice: InstrumentChoice, choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[instrumentChoice]?[choice] ?? false },
            set: { newValue in
                self.intervalLabels[instrumentChoice]?[choice] = newValue
                self.saveIntervalLabels()
            }
        )
    }
    
    @MainActor
    public func colorPaletteBinding(for instrumentChoice: InstrumentChoice) -> Binding<ColorPalette> {
        Binding(
            get: { self.colorPalettes[instrumentChoice] ?? IntervalColorPalette.homey },
            set: { newValue in
                self.colorPalettes[instrumentChoice] = newValue
                self.colorPaletteIDs[instrumentChoice] = newValue.id
                self.saveColorPaletteIDs()
            }
        )
    }
    
    @MainActor
    public func outlineBinding(for instrumentChoice: InstrumentChoice) -> Binding<Bool> {
        Binding(
            get: { self.outline[instrumentChoice] ?? false },
            set: { newValue in
                self.outline[instrumentChoice] = newValue
                self.saveOutline()
            }
        )
    }
    
    /// Iterates through every instrument choice and, if the palette matches the deleted palette,
    /// replaces it with the provided default palette.
    @MainActor
    func replaceDeletedPalette(_ deletedPalette: ColorPalette, with defaultPalette: ColorPalette) {
        // Assuming InstrumentChoice.allInstruments provides all instrument choices:
        InstrumentChoice.allInstruments.forEach { instrument in
            if let currentPalette = colorPalettes[instrument],
               currentPalette.id == deletedPalette.id {
                colorPalettes[instrument] = defaultPalette
            }
        }
        // If needed, you can also update any persisted state here
        // e.g., saveColorPaletteIDs() if that is critical to save the new mappings.
    }
}
