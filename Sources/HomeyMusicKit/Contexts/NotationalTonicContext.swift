public class NotationalTonicContext: NotationalContext, @unchecked Sendable {
    
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
