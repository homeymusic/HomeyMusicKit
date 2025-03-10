import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    // Nested dictionaries mapping each instrument type to its own label state.
    @Published public var noteLabels: [InstrumentType: [NoteLabelChoice: Bool]] = [:]
    @Published public var intervalLabels: [InstrumentType: [IntervalLabelChoice: Bool]] = [:]
    @Published public var colorPalette: [InstrumentType: ColorPaletteChoice] = [:]
    @Published public var outline: [InstrumentType: Bool] = [:]
    
    public init() {
        // Initialize each instrument with its default settings.
        InstrumentType.allCases.forEach { instrumentType in
            noteLabels[instrumentType] = Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) })
            intervalLabels[instrumentType] = Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { ($0, false) })
            colorPalette[instrumentType] = .subtle
            outline[instrumentType] = true
        }
    }
    
    /// Binding for note labels for a given instrumentType.
    public func noteBinding(for instrumentType: InstrumentType, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrumentType]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrumentType]?[choice] = newValue
                print("instrumentType", instrumentType)
                print("self.noteLabels[instrumentType]?[choice] = newValue", self.noteLabels[instrumentType]?[choice])
            }
        )
    }
    
    /// Binding for interval labels for a given instrumentType.
    public func intervalBinding(for instrumentType: InstrumentType, choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[instrumentType]?[choice] ?? false },
            set: { newValue in
                self.intervalLabels[instrumentType]?[choice] = newValue
            }
        )
    }
    
    /// Binding for color palette for a given instrumentType.
    public func colorPaletteBinding(for instrumentType: InstrumentType) -> Binding<ColorPaletteChoice> {
        Binding(
            get: { self.colorPalette[instrumentType] ?? .subtle },
            set: { newValue in
                self.colorPalette[instrumentType] = newValue
            }
        )
    }
    
    /// Binding for the outline property for a given instrument.
    public func outlineBinding(for instrumentType: InstrumentType) -> Binding<Bool> {
        Binding(
            get: { self.outline[instrumentType] ?? false },
            set: { newValue in
                self.outline[instrumentType] = newValue
            }
        )
    }
    
    public func labelsCount(for instrumentType: InstrumentType) -> Int {
        Array(noteLabels[instrumentType]!.values).filter{$0}.count +
        Array(intervalLabels[instrumentType]!.values).filter{$0}.count
    }
        
}
