import SwiftUI

public class NotationalContext: ObservableObject, @unchecked Sendable {
    @Published public var noteLabels: [NoteLabelChoice: Bool] = [:]
    @Published public var intervalLabels: [IntervalLabelChoice: Bool] = [:]

    public init() {
        // Initialize all label choices to false by default
        NoteLabelChoice.allCases.forEach { choice in
            noteLabels[choice] = false
        }
        
        IntervalLabelChoice.allCases.forEach { choice in
            intervalLabels[choice] = false
        }
    }
    
    /// A convenient way to get/set a Binding<Bool> for a specific NoteLabelChoice
    public func noteBinding(for choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[choice] ?? false },
            set: { self.noteLabels[choice] = $0 }
        )
    }
    
    /// A convenient way to get/set a Binding<Bool> for a specific NoteLabelChoice
    public func intervalBinding(for choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[choice] ?? false },
            set: { self.intervalLabels[choice] = $0 }
        )
    }

}
