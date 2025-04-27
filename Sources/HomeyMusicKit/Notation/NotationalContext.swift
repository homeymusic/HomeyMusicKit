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
    
    public var colorPalettes: [InstrumentChoice: ColorPalette]
    
    // Private dictionary that holds UUIDs for persistence.
    private var colorPaletteIDs: [InstrumentChoice: UUID] = [:]


    @MainActor
    public func colorPalette(for instrumentChoice: InstrumentChoice) -> ColorPalette {
        colorPalettes[instrumentChoice] ?? IntervalColorPalette.homey
    }
    
    @MainActor
    public class func defaultColorPalette(for instrumentChoice: InstrumentChoice) -> IntervalColorPalette {
        return IntervalColorPalette.homey
    }
    
    // MARK: - Initialization
    @MainActor
    public init() {
        // Provide temporary values so self is available.
        self.colorPalettes = [:]
        
        if let data = UserDefaults.standard.data(forKey: self.key(for: "colorPaletteIDs")),
           let decoded = try? JSONDecoder().decode([InstrumentChoice: UUID].self, from: data) {
            self.colorPaletteIDs = decoded
        }
        
        // Ensure every instrument type has a value.
        InstrumentChoice.allInstruments.forEach { instrumentChoice in
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
    
    @MainActor
    public func isColorPaletteDefault(for instrumentChoice: InstrumentChoice) -> Bool {
        return self.colorPalette(for: instrumentChoice).name == IntervalColorPalette.homey.name
    }
    
    @MainActor
    public func resetColorPalette(for instrumentChoice: InstrumentChoice) {
        let paletteBinding = colorPaletteBinding(for: instrumentChoice)
        paletteBinding.wrappedValue = IntervalColorPalette.homey
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
    func replaceDeletedPalette(_ deletedPalette: ColorPalette, with defaultPalette: ColorPalette) {
        // Assuming InstrumentChoice.allInstruments provides all instrument choices:
        InstrumentChoice.allInstruments.forEach { instrument in
            if let currentPalette = colorPalettes[instrument],
               currentPalette.id == deletedPalette.id {
                colorPalettes[instrument] = defaultPalette
            }
        }
    }
}
