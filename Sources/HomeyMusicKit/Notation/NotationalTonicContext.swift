import SwiftUI

public class NotationalTonicContext: NotationalContext {
    
    // Persisted properties specific to the tonic context.
    @AppStorage("showHelp") public var showHelp: Bool = false
    @AppStorage("showTonicPicker") public var showTonicPicker: Bool = false
    
    // Override the key prefix so that all persisted keys are namespaced.
    public override var keyPrefix: String { "tonic" }
    
    public override var defaultNoteLabels: [InstrumentChoice: [NoteLabelChoice: Bool]] {
        InstrumentChoice.allCases.reduce(into: [:]) { result, instrumentChoice in
            result[instrumentChoice] = NoteLabelChoice.allCases.reduce(into: [:]) { innerDict, noteLabel in
                innerDict[noteLabel] = (noteLabel == .letter)
            }
        }
    }
    
    /// Convenience computed property.
    public var showModes: Bool {
        (self.noteLabels[.tonicPicker]?[.mode] ?? false) ||
        (self.noteLabels[.tonicPicker]?[.guide] ?? false)
    }
    
}
