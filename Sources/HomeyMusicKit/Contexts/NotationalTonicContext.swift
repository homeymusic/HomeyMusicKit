public class NotationalTonicContext: NotationalContext, @unchecked Sendable {
    
    public var showModes: Bool {
        self.noteLabels[.tonicPicker]![.mode]! || self.noteLabels[.tonicPicker]![.guide]!
    }
    
}
