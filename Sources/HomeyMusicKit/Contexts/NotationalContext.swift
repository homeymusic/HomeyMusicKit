import SwiftUI

public class NotationalContext: ObservableObject {
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
    
    /// Sets the dictionary entry for the given label choice,
    /// then reassigns `enabledLabels` so SwiftUI sees the change.
    private func setNoteLabel(_ choice: NoteLabelChoice, to newValue: Bool) {
        noteLabels[choice] = newValue
        // This reassign forces SwiftUI to register a new value for the dictionary
        noteLabels = noteLabels
    }
    
    /// A convenient way to get/set a Binding<Bool> for a specific NoteLabelChoice
    public func noteBinding(for choice: NoteLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.noteLabels[choice] ?? false },
            set: { self.setNoteLabel(choice, to: $0) }
        )
    }
    
    private func setIntervalLabel(_ choice: IntervalLabelChoice, to newValue: Bool) {
        intervalLabels[choice] = newValue
        // This reassign forces SwiftUI to register a new value for the dictionary
        intervalLabels = intervalLabels
    }
    
    /// A convenient way to get/set a Binding<Bool> for a specific NoteLabelChoice
    public func intervalBinding(for choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: { self.intervalLabels[choice] ?? false },
            set: { self.setIntervalLabel(choice, to: $0) }
        )
    }

}
