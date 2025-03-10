import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    // Nested dictionaries mapping each instrument type to its own label state.
    @Published public var noteLabels: [InstrumentType: [NoteLabelChoice: Bool]] = [:]
    @Published public var intervalLabels: [InstrumentType: [IntervalLabelChoice: Bool]] = [:]
    @Published public var colorPalette: [InstrumentType: ColorPaletteChoice] = [:]
    @Published public var outline: [InstrumentType: Bool] = [:]

    public init() {
        // Initialize each instrument with its default settings.
        InstrumentType.allCases.forEach { instrument in
            noteLabels[instrument] = Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) })
            intervalLabels[instrument] = Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { ($0, false) })
            colorPalette[instrument] = .subtle
            outline[instrument] = true
        }
    }
    
    /// Binding for note labels for a given instrument.
    public func noteBinding(for instrument: InstrumentType, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrument]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrument]?[choice] = newValue
            }
        )
    }
    
    /// Binding for interval labels for a given instrument.
    public func intervalBinding(for instrument: InstrumentType, choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[instrument]?[choice] ?? false },
            set: { newValue in
                self.intervalLabels[instrument]?[choice] = newValue
            }
        )
    }
    
    /// Binding for color palette for a given instrument.
    public func colorPaletteBinding(for instrument: InstrumentType) -> Binding<ColorPaletteChoice> {
        Binding(
            get: { self.colorPalette[instrument] ?? .subtle },
            set: { newValue in
                self.colorPalette[instrument] = newValue
            }
        )
    }
 
    /// Binding for the outline property for a given instrument.
    public func outlineBinding(for instrument: InstrumentType) -> Binding<Bool> {
        Binding(
            get: { self.outline[instrument] ?? false },
            set: { newValue in
                self.outline[instrument] = newValue
            }
        )
    }
    
}
