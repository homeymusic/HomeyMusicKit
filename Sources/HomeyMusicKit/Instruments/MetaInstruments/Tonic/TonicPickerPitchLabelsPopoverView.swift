import SwiftUI

struct TonicPickerPitchLabelsPopoverView: View {
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var notationalTonicContext: NotationalTonicContext

    var body: some View {
        VStack(spacing: 0.0) {
            Grid {
                ForEach(NoteLabelChoice.pitchClassCases, id: \.self) {key in
                    if key != .accidentals {
                        GridRow {
                            key.image
                                .gridCellAnchor(.center)
                                .foregroundColor(.white)
                            Toggle(key.label,
                                   isOn: notationalTonicContext.noteBinding(for: .tonicPicker, choice: key))
                            .gridCellAnchor(.leading)
                            .tint(Color.gray)
                            .foregroundColor(.white)
                        }
                        if key == .letter {
                            GridRow {
                                Image(systemName: NoteLabelChoice.accidentals.icon)
                                    .gridCellAnchor(.center)
                                Picker("", selection: $tonalContext.accidental) {
                                    ForEach(Accidental.displayCases) { accidental in
                                        Text(accidental.icon)
                                            .tag(accidental as Accidental)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
                
                Divider()
                
                ForEach(IntervalLabelChoice.intervalClassCases, id: \.self) {key in
                    GridRow {
                        key.image
                            .gridCellAnchor(.center)
                            .foregroundColor(.white)
                        Toggle(key.label,
                               isOn: notationalTonicContext.intervalBinding(for: .tonicPicker, choice: key))
                        .gridCellAnchor(.leading)
                        .tint(Color.gray)
                    }
                    if key == .symbol {
                        Divider()
                    }
                }
                
                Divider()
                
                ForEach(NoteLabelChoice.modeCases, id: \.self) {key in
                    GridRow {
                        key.image
                            .gridCellAnchor(.center)
                            .foregroundColor(.white)
                        Toggle(key.label,
                               isOn: notationalTonicContext.noteBinding(for: .tonicPicker, choice: key))
                        .gridCellAnchor(.leading)
                        .tint(Color.gray)
                        .foregroundColor(.white)
                    }
                }
                
            }
            .padding(10)
        }
    }
}
