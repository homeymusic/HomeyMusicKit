import SwiftUI

@Observable
public class NotationalTonicContext: NotationalContext {
    
    // Persisted properties specific to the tonic context.
    @ObservationIgnored
    @AppStorage("showHelp") public var showHelpRaw: Bool = false
    
    public var showHelp: Bool = false {
        didSet {
            showHelpRaw = showHelp
        }
    }
    
    @ObservationIgnored
    @AppStorage("showTonicPicker") public var showTonicPickerRaw: Bool = false
    public var showTonicPicker: Bool = false {
        didSet {
            showTonicPickerRaw = showTonicPicker
        }
    }

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
    
    override public init() {
        super.init()
        self.showHelp = showHelpRaw
        self.showTonicPicker = showTonicPickerRaw
    }
    
}
