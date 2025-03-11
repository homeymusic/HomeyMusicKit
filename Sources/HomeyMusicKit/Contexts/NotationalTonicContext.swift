import SwiftUI

public class NotationalTonicContext: NotationalContext, @unchecked Sendable {

    @Published public var showHelp: Bool = false
    @Published public var showTonicPicker: Bool = false

    /// Override default note labels to have `.letter` true for the tonic picker.
    public override class func defaultNoteLabels() -> [InstrumentType: [NoteLabelChoice: Bool]] {
        var defaults = super.defaultNoteLabels()
        // Ensure that your InstrumentType has a .tonicPicker case.
        defaults[.tonicPicker]?[.letter] = true
        return defaults
    }
    
    public var showModes: Bool {
        (self.noteLabels[.tonicPicker]?[.mode] ?? false) ||
        (self.noteLabels[.tonicPicker]?[.guide] ?? false)
    }
        
}
