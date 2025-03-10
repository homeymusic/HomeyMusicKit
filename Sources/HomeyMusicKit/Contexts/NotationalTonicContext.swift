public class NotationalTonicContext: NotationalContext {
    public var showTonicLabels: Bool {
        noteLabels.values.contains(true) || intervalLabels.values.contains(true)
    }
}
