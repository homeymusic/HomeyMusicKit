import SwiftUI

// MARK: - PitchDirectionPickerView
public struct PitchDirectionPickerView: View {
    @Environment(TonalContext.self) var tonalContext
    
    public init() { }
    
    public var body: some View {
        // A horizontal stack that looks like a segmented control
        HStack(spacing: 0) {
            ForEach(PitchDirection.allCases, id: \.self) { direction in
                pitchDirectionButton(direction)
                
                // Insert a vertical divider after downward and mixed, but not after upward
                if direction != .upward {
                    divider
                }
            }
        }
        .background(Color.systemGray6)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    /// A single segment button for a given PitchDirection.
    private func pitchDirectionButton(_ direction: PitchDirection) -> some View {
        let isSelected = (tonalContext.pitchDirection == direction)
        
        return Button(action: {
            // Only change selection if it's *not* already selected
            tonalContext.pitchDirection = direction
            buzz()
        }) {
            Color.clear.overlay(
                Image(systemName: direction.icon)
                    .foregroundColor(.white)
            )
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 44)
            .background(isSelected ? Color.systemGray2 : Color.clear)
        }
        // Disable the button if it's the currently selected direction
        .disabled(isSelected)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.systemGray4)
            .frame(width: 1, height: 17.5)
    }
}
