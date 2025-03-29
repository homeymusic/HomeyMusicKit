import SwiftUI

public struct OctaveShiftView: View {
    @Environment(TonalContext.self) var tonalContext
    
    public init() { }
    
    public var body: some View {
        HStack(spacing: 5) {
            // Downward octave shift button
            Button(action: {
                tonalContext.shiftDownOneOctave()
            }, label: {
                Image(systemName: "water.waves.and.arrow.down")
                    .foregroundColor(tonalContext.canShiftDownOneOctave ? .white : Color.systemGray4)
            })
            .disabled(!tonalContext.canShiftDownOneOctave)
            
            // Display the octave shift value
            Text(tonalContext.octaveShift.formatted(.number.sign(strategy: .always(includingZero: false))))
                .foregroundColor(.white)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 41, alignment: .center)
            
            // Upward octave shift button
            Button(action: {
                tonalContext.shiftUpOneOctave()
            }, label: {
                Image(systemName: "water.waves.and.arrow.up")
                    .foregroundColor(tonalContext.canShiftUpOneOctave ? .white : Color.systemGray4)
            })
            .disabled(!tonalContext.canShiftUpOneOctave)
        }
    }
}
