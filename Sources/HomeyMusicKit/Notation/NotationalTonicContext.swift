import SwiftUI

@Observable
public class NotationalTonicContext: NotationalContext {
    
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
    public override var keyPrefix: String { "tonic" }
    
    public override var defaultNoteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        InstrumentChoice.allCases.reduce(into: [:]) { result, instrumentChoice in
            result[instrumentChoice] = NoteLabelChoice.allCases.reduce(into: [:]) { innerDict, noteLabel in
                innerDict[noteLabel] = (noteLabel == .letter || noteLabel == .mode)
            }
        }
    }
    
    override public init() {
        super.init()
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
 
