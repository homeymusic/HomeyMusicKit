import SwiftUI

public class NotationalTonicContext: NotationalContext, @unchecked Sendable {
    
    // These properties are now persisted.
    @AppStorage("showHelp") public var showHelp: Bool = false
    @AppStorage("showTonicPicker") public var showTonicPicker: Bool = false

    /// Override default note labels to have `.letter` true for the tonic picker.
    public override class func defaultNoteLabels() -> [InstrumentChoice: [NoteLabelChoice: Bool]] {
        var defaults = super.defaultNoteLabels()
        defaults[.tonicPicker]?[.letter] = true
        return defaults
    }
    
    public override init() {
        super.init()
        noteLabels[.tonicPicker] = Self.defaultNoteLabels()[.tonicPicker]
        intervalLabels[.tonicPicker] = defaultIntervalLabels[.tonicPicker]
        colorPalette[.tonicPicker] = .subtle
        outline[.tonicPicker] = true
    }

    public var showModes: Bool {
        (self.noteLabels[.tonicPicker]?[.mode] ?? false) ||
        (self.noteLabels[.tonicPicker]?[.guide] ?? false)
    }
        
}
