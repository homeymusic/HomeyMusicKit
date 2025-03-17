import SwiftUI

public class NotationalTonicContext: NotationalContext, @unchecked Sendable {
    
    // Persisted properties specific to the tonic context.
    @AppStorage("showHelp") public var showHelp: Bool = false
    @AppStorage("showTonicPicker") public var showTonicPicker: Bool = false
    
    // Override the key prefix so that all persisted keys are namespaced.
    public override var keyPrefix: String { "tonic" }
    
    /// Override default note labels so that for the tonic picker the `.letter` flag is set.
    public override class func defaultNoteLabels() -> [InstrumentChoice: [NoteLabelChoice: Bool]] {
        var defaults = super.defaultNoteLabels()
        defaults[.tonicPicker]?[.letter] = true
        return defaults
    }
    
    public override init() {
        super.init()
        // Only update the values for .tonicPicker if they have not been modified.
        if noteLabels[.tonicPicker] == NotationalContext.defaultNoteLabels()[.tonicPicker] {
            noteLabels[.tonicPicker] = NotationalTonicContext.defaultNoteLabels()[.tonicPicker]
        }
        if intervalLabels[.tonicPicker] == defaultIntervalLabels[.tonicPicker] {
            intervalLabels[.tonicPicker] = defaultIntervalLabels[.tonicPicker]
        }
        if colorPalette[.tonicPicker] == NotationalContext.defaultColorPalette(for: .tonicPicker) {
            colorPalette[.tonicPicker] = .subtle
        }
        if outline[.tonicPicker] == NotationalContext.defaultOutline(for: .tonicPicker) {
            outline[.tonicPicker] = true
        }
    }
    
    /// Convenience computed property.
    public var showModes: Bool {
        (self.noteLabels[.tonicPicker]?[.mode] ?? false) ||
        (self.noteLabels[.tonicPicker]?[.guide] ?? false)
    }
    
    /// Override resetLabels so that when resetting .tonicPicker,
    /// it uses the tonic-specific defaults (with .letter set to true).
    public override func resetLabels(for instrumentChoice: InstrumentChoice) {
        if instrumentChoice == .tonicPicker {
            noteLabels[instrumentChoice] = NotationalTonicContext.defaultNoteLabels()[instrumentChoice]
            intervalLabels[instrumentChoice] = defaultIntervalLabels[instrumentChoice]
        } else {
            super.resetLabels(for: instrumentChoice)
        }
    }
}
