import SwiftUI
import SwiftData

@Observable
public class NotationalContext {
    
    // MARK: – Persistence Key Helper
    public var keyPrefix: String { "" }
    public func key(for base: String) -> String {
        keyPrefix.isEmpty ? base : "\(keyPrefix)_\(base)"
    }
    
    // MARK: – Persisted Properties
    public var noteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        didSet { saveNoteLabels() }
    }
    public var intervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] {
        didSet { saveIntervalLabels() }
    }
    public var colorPalettes: [InstrumentChoice: ColorPalette]
    private var colorPaletteIDs: [InstrumentChoice: UUID] = [:]
    public var outline: [InstrumentChoice: Bool] {
        didSet { saveOutline() }
    }
    
    public var showLabelsPopover: Bool = false
    public var showColorPalettePopover: Bool = false
    public var showEditColorPaletteSheet: Bool = false
    
    public let outlineLabel: String = "Outline"
    
    public let defaultIntervalLabels: [InstrumentChoice: [IntervalLabelChoice: Bool]] = {
        Dictionary(uniqueKeysWithValues:
            InstrumentChoice.allCases.map { ic in
                (ic,
                 Dictionary(uniqueKeysWithValues:
                    IntervalLabelChoice.allCases.map { ($0, $0 == .symbol) }
                 )
                )
            }
        )
    }()
    
    public var defaultNoteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        Dictionary(uniqueKeysWithValues:
            InstrumentChoice.allCases.map { ic in
                let dict = Dictionary(uniqueKeysWithValues:
                    NoteLabelChoice.allCases.map {
                        ($0, $0 == .octave && ic != .tonicPicker && ic != .modePicker)
                    }
                )
                return (ic, dict)
            }
        )
    }
    
    // MARK: – Palette Lookup
    
    /// Picks the palette for an instrument in this context, falling back to Homey.
    @MainActor
    public func colorPalette(
        for instrumentChoice: InstrumentChoice,
        in modelContext: ModelContext
    ) -> ColorPalette {
        colorPalettes[instrumentChoice]
            ?? IntervalColorPalette.homey(in: modelContext)
    }
    
    /// The default interval palette for an instrument in this context.
    @MainActor
    public class func defaultColorPalette(
        for instrumentChoice: InstrumentChoice,
        in modelContext: ModelContext
    ) -> IntervalColorPalette {
        IntervalColorPalette.homey(in: modelContext)
    }
    
    /// Default outline toggle.
    public class func defaultOutline(for instrumentChoice: InstrumentChoice) -> Bool {
        true
    }
    
    // MARK: – Initialization
    
    @MainActor
    public init() {
        // Initialize with empty placeholders; actual palettes will be loaded later.
        self.noteLabels     = [:]
        self.intervalLabels = [:]
        self.outline        = [:]
        self.colorPalettes  = [:]
        
        // Load persisted noteLabels
        if let data = UserDefaults.standard.data(forKey: key(for: "noteLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [NoteLabelChoice: Bool]].self, from: data) {
            self.noteLabels = decoded
        } else {
            self.noteLabels = defaultNoteLabels
        }
        
        // Load persisted intervalLabels
        if let data = UserDefaults.standard.data(forKey: key(for: "intervalLabels")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: [IntervalLabelChoice: Bool]].self, from: data) {
            self.intervalLabels = decoded
        } else {
            self.intervalLabels = defaultIntervalLabels
        }
        
        // Load persisted outline
        if let data = UserDefaults.standard.data(forKey: key(for: "outline")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: Bool].self, from: data) {
            self.outline = decoded
        } else {
            self.outline = Dictionary(uniqueKeysWithValues:
                InstrumentChoice.allInstruments.map { (ic, _) in
                    (ic, NotationalContext.defaultOutline(for: ic))
                }
            )
        }
        
        // Load stored palette IDs
        if let data = UserDefaults.standard.data(forKey: key(for: "colorPaletteIDs")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: UUID].self, from: data) {
            self.colorPaletteIDs = decoded
        }
        
        // Load persisted booleans
        self.showLabelsPopover       = UserDefaults.standard.object(forKey: key(for: "showLabelsPopover")) as? Bool ?? false
        self.showColorPalettePopover = UserDefaults.standard.object(forKey: key(for: "showPalettePopover")) as? Bool ?? false
        self.showEditColorPaletteSheet = UserDefaults.standard.object(forKey: key(for: "showEditColorPaletteSheet")) as? Bool ?? false
    }
    
    // MARK: – Fetch Helpers
    
    @MainActor
    private func fetchColorPalette(
        with id: UUID,
        from modelContext: ModelContext
    ) -> ColorPalette? {
        if let pitch = try? modelContext.fetch(
            FetchDescriptor<PitchColorPalette>(predicate: #Predicate { $0.id == id })
        ).first {
            return pitch
        }
        if let interval = try? modelContext.fetch(
            FetchDescriptor<IntervalColorPalette>(predicate: #Predicate { $0.id == id })
        ).first {
            return interval
        }
        return nil
    }
    
    // MARK: – Palette Persistence
    
    @MainActor
    public func loadColorPaletteIDs(modelContext: ModelContext) {
        for ic in InstrumentChoice.allInstruments {
            if let stored = colorPaletteIDs[ic],
               let fetched = fetchColorPalette(with: stored, from: modelContext) {
                colorPalettes[ic] = fetched
            } else {
                colorPalettes[ic] = IntervalColorPalette.homey(in: modelContext)
            }
        }
    }
    
    public func saveNoteLabels() { /* unchanged */ }
    public func saveIntervalLabels() { /* unchanged */ }
    public func saveOutline() { /* unchanged */ }
    public func saveColorPaletteIDs() {
        if let data = try? JSONEncoder().encode(colorPaletteIDs) {
            UserDefaults.standard.set(data, forKey: key(for: "colorPaletteIDs"))
        }
    }
    
    // MARK: – Utility Methods
    
    public func areLabelsDefault(for instrumentChoice: InstrumentChoice) -> Bool { /* unchanged */ }
    public func resetLabels(for instrumentChoice: InstrumentChoice) { /* unchanged */ }
    
    @MainActor
    public func isColorPaletteDefault(
        for instrumentChoice: InstrumentChoice,
        in modelContext: ModelContext
    ) -> Bool {
        colorPalette(for: instrumentChoice, in: modelContext).name
          == IntervalColorPalette.homey(in: modelContext).name
        && outline[instrumentChoice] == NotationalContext.defaultOutline(for: instrumentChoice)
    }
    
    @MainActor
    public func resetColorPalette(
        for instrumentChoice: InstrumentChoice,
        in modelContext: ModelContext
    ) {
        let binding = colorPaletteBinding(for: instrumentChoice, in: modelContext)
        binding.wrappedValue = IntervalColorPalette.homey(in: modelContext)
        outline[instrumentChoice] = NotationalContext.defaultOutline(for: instrumentChoice)
        buzz()
    }
    
    @MainActor
    public func colorPaletteBinding(
        for instrumentChoice: InstrumentChoice,
        in modelContext: ModelContext
    ) -> Binding<ColorPalette> {
        Binding(
            get: {
                colorPalettes[instrumentChoice]
                  ?? IntervalColorPalette.homey(in: modelContext)
            },
            set: { newVal in
                colorPalettes[instrumentChoice] = newVal
                colorPaletteIDs[instrumentChoice] = newVal.id
                saveColorPaletteIDs()
            }
        )
    }
    
    @MainActor
    public func outlineBinding(
        for instrumentChoice: InstrumentChoice
    ) -> Binding<Bool> {
        Binding(
            get: { outline[instrumentChoice] ?? false },
            set: {
                outline[instrumentChoice] = $0
                saveOutline()
            }
        )
    }
    
    @MainActor
    func replaceDeletedPalette(
        _ deleted: ColorPalette,
        with `default`: ColorPalette
    ) {
        InstrumentChoice.allInstruments.forEach { ic in
            if colorPalettes[ic]?.id == deleted.id {
                colorPalettes[ic] = `default`
            }
        }
    }
}
