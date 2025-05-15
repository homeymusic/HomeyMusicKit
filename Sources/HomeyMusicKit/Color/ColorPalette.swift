import SwiftUI
import SwiftData

public protocol ColorPalette: AnyObject, Observable {
    
    // MARK: - Basic Info
    var id: UUID { get set }
    var systemIdentifier: String? { get set }
    var name: String { get set }
    var position: Int { get set }
    var isSystemPalette: Bool { get }
    
    // MARK: - Core Color Methods
    func majorMinorColor(majorMinor: MajorMinor) -> Color
    func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func inactiveColor(isNatural: Bool) -> Color
    func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func activeOutlineColor(majorMinor: MajorMinor) -> Color
    func inactiveOutlineColor(majorMinor: MajorMinor) -> Color
    
    // MARK: - Additional Color
    var benignColor: Color { get }
        
}


extension ColorPalette {
    public var isSystemPalette: Bool {
        systemIdentifier != nil
    }
}

public extension ModelContext {
    @MainActor
    func ensureColorPalette(on instrument: any Instrument) {
        guard
            instrument.intervalColorPalette == nil,
            instrument.pitchColorPalette    == nil
        else { return }
        
        let descriptor = FetchDescriptor<IntervalColorPalette>(
            sortBy: [SortDescriptor(\.position)]
        )
        
        // Try to fetch any existing palettes
        var palettes = (try? fetch(descriptor)) ?? []
        
        // If none exist, seed the system defaults and re-fetch
        if palettes.isEmpty {
            IntervalColorPalette.seedSystemIntervalPalettes(modelContext: self)
            PitchColorPalette.seedSystemPitchPalettes(modelContext: self)
            palettes = (try? fetch(descriptor)) ?? []
        }
        
        // Assign the first available interval palette
        if let first = palettes.first {
            instrument.intervalColorPalette = first
        }
    }
}
