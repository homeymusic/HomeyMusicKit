import SwiftUI

@Observable
public class NotationalTonicContext {
    
    public var showHelp: Bool = false
    
    @ObservationIgnored
    @AppStorage("showTonicPicker") public var showTonicPickerRaw: Bool = false
    public var showTonicPicker: Bool = false {
        didSet {
            showTonicPickerRaw = showTonicPicker
        }
    }

    @ObservationIgnored
    @AppStorage("showModePicker") public var showModePickerRaw: Bool = false
    public var showModePicker: Bool = false {
        didSet {
            showModePickerRaw = showModePicker
        }
    }
    
    // Override the key prefix so that all persisted keys are namespaced.
    public var keyPrefix: String { "tonic" }
    
    // MARK: - Persisted Properties
    /// Dictionaries mapping each instrument type to its own label state.
    public var noteLabels: [PickerChoice: [NoteLabelChoice: Bool]] {
        didSet { saveNoteLabels() }
    }
    public var intervalLabels: [PickerChoice: [IntervalLabelChoice: Bool]] {
        didSet { saveIntervalLabels() }
    }
    
    public let defaultIntervalLabels: [PickerChoice: [IntervalLabelChoice: Bool]] = {
        Dictionary(uniqueKeysWithValues: PickerChoice.allCases.map { pickerChoice in
            (pickerChoice, Dictionary(uniqueKeysWithValues: IntervalLabelChoice.allCases.map { choice in
                (choice, choice == .symbol)
            }))
        })
    }()
    
    public var defaultNoteLabels: [PickerChoice: [NoteLabelChoice: Bool]] {
        Dictionary(uniqueKeysWithValues: PickerChoice.allCases.map { pickerChoice in
            let noteLabels = Dictionary(uniqueKeysWithValues: NoteLabelChoice.allCases.map { noteLabel in
                (noteLabel,
                 (noteLabel == .octave  &&
                  (pickerChoice != .tonicPicker || pickerChoice != .modePicker)))
            })
            return (pickerChoice, noteLabels)
        })
    }

    public init() {
        self.showTonicPicker = showTonicPickerRaw
        self.showModePicker = showModePickerRaw
    }
    
    public func resetLabels() {
        if showTonicPicker {
            // Reset interval labels completely
            intervalLabels[.tonicPicker] = defaultIntervalLabels[.tonicPicker]

            // Merge all defaults EXCEPT .map and .mode
            noteLabels[.tonicPicker] = (noteLabels[.tonicPicker] ?? [:]).merging(
                (defaultNoteLabels[.tonicPicker] ?? [:]).filter { ![.map, .mode].contains($0.key) }
            ) { _, new in new}
        }
        
        if showModePicker {
            // Explicitly reset just .mode and .map
            noteLabels[.tonicPicker]?[.mode] = defaultNoteLabels[.tonicPicker]?[.mode] ?? false
            noteLabels[.tonicPicker]?[.map]  = defaultNoteLabels[.tonicPicker]?[.map]  ?? false
        }
        
        buzz()
    }
    
}
 
