import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    // Nested dictionaries mapping each instrument type to its own label state.
    @Published public var noteLabels: [InstrumentType: [NoteLabelChoice: Bool]] = [:]
    @Published public var intervalLabels: [InstrumentType: [IntervalLabelChoice: Bool]] = [:]
    @Published public var colorPalette: ColorPaletteChoice = .subtle

    public init() {
        // Initialize each instrument with its default settings.
        InstrumentType.allCases.forEach { instrument in
            noteLabels[instrument] = Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) })
            intervalLabels[instrument] = Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { ($0, false) })
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
}
