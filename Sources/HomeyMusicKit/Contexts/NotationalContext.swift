import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    
    // Nested dictionaries mapping each instrument type to its own label state.
    @Published public var noteLabels: [InstrumentType: [NoteLabelChoice: Bool]] = [:]
    @Published public var intervalLabels: [InstrumentType: [IntervalLabelChoice: Bool]] = [:]
    @Published public var colorPalette: [InstrumentType: ColorPaletteChoice] = [:]
    @Published public var outline: [InstrumentType: Bool] = [:]
    @Published public var showLabelsPopover: Bool = false
    @Published public var showPalettePopover: Bool = false
    
    /// Default interval labels (all false, except `symbol` is true)
    private let defaultIntervalLabels: [InstrumentType: [IntervalLabelChoice: Bool]] = {
        Dictionary(uniqueKeysWithValues: InstrumentType.allCases.map { instrumentType in
            (instrumentType, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                (choice, choice == .symbol)
            }))
        })
    }()
    
    /// Class function returning the default note labels (all false).
    public class func defaultNoteLabels() -> [InstrumentType: [NoteLabelChoice: Bool]] {
        Dictionary(uniqueKeysWithValues: InstrumentType.allCases.map { instrumentType in
            (instrumentType, Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { ($0, false) }))
        })
    }
    
    /// Class function returning the default color palette for an instrument.
    public class func defaultColorPalette(for instrumentType: InstrumentType) -> ColorPaletteChoice {
        return .subtle
    }

    /// Class function returning the default outline for an instrument.
    public class func defaultOutline(for instrumentType: InstrumentType) -> Bool {
        return true
    }

    public init() {
        let defaults = Self.defaultNoteLabels()
        InstrumentType.allCases.forEach { instrumentType in
            noteLabels[instrumentType] = defaults[instrumentType]
            intervalLabels[instrumentType] = defaultIntervalLabels[instrumentType]
            colorPalette[instrumentType] = .subtle
            outline[instrumentType] = true
        }
    }
    
    /// Determines if the labels for a given instrument are at their default settings.
    public func areLabelsDefault(for instrumentType: InstrumentType) -> Bool {
        guard let currentNoteLabels = noteLabels[instrumentType],
              let currentIntervalLabels = intervalLabels[instrumentType] else {
            return false
        }
        
        return currentNoteLabels == Self.defaultNoteLabels()[instrumentType]! &&
               currentIntervalLabels == defaultIntervalLabels[instrumentType]!
    }
    
    /// Resets the note and interval labels for a specific instrument to their default values.
    /// - Parameter instrumentType: The instrument whose labels should be reset.
    public func resetLabels(for instrumentType: InstrumentType) {
        noteLabels[instrumentType] = Self.defaultNoteLabels()[instrumentType]
        intervalLabels[instrumentType] = defaultIntervalLabels[instrumentType]
    }
    
    /// Determines if the color palette for a given instrument is at its default value.
    public func isColorPaletteDefault(for instrumentType: InstrumentType) -> Bool {
        self.colorPalette[instrumentType] == Self.defaultColorPalette(for: instrumentType) &&
        self.outline[instrumentType] == Self.defaultOutline(for: instrumentType)
    }
    
    /// Resets the color palette for a specific instrument to its default value.
    public func resetColorPalette(for instrumentType: InstrumentType) {
        self.colorPalette[instrumentType] = Self.defaultColorPalette(for: instrumentType)
        self.outline[instrumentType] = Self.defaultOutline(for: instrumentType)
    }

    /// Binding for note labels for a given instrumentType.
    public func noteBinding(for instrumentType: InstrumentType, choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[instrumentType]?[choice] ?? false },
            set: { newValue in
                self.noteLabels[instrumentType]?[choice] = newValue
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
        Array(noteLabels[instrumentType]!.values).filter { $0 }.count +
        Array(intervalLabels[instrumentType]!.values).filter { $0 }.count
    }
}
