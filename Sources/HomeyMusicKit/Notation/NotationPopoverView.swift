import SwiftUI

struct NotationPopoverView: View {
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var notationalContext: NotationalContext

    var body: some View {
        VStack(spacing: 0.0) {
            Grid {
                ForEach(NoteLabelChoice.pitchCases, id: \.self) {key in
                    if key != .octave && key != .accidentals {
                        GridRow {
                            key.image
                                .gridCellAnchor(.center)
                                .foregroundColor(.white)
                            Toggle(key.label,
                                   isOn: notationalContext.noteBinding(for: instrumentalContext.instrumentChoice, choice: key))
                            .gridCellAnchor(.leading)
                            .tint(Color.gray)
                            .foregroundColor(.white)
                        }
                        if key == .letter {
                            GridRow {
                                Image(systemName: NoteLabelChoice.accidentals.icon)
                                    .gridCellAnchor(.center)
                                    .foregroundColor(.white)
                                Picker("", selection: $tonalContext.accidental) {
                                    ForEach(Accidental.displayCases) { accidental in
                                        Text(accidental.icon)
                                            .tag(accidental as Accidental)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            GridRow {
                                NoteLabelChoice.octave.image
                                    .gridCellAnchor(.center)
                                    .foregroundColor(.white)
                                Toggle(NoteLabelChoice.octave.label,
                                       isOn: notationalContext.noteBinding(for: instrumentalContext.instrumentChoice, choice: NoteLabelChoice.octave))
                                .gridCellAnchor(.leading)
                                .tint(Color.gray)
                            }
                        }
                    }
                }
                Divider()
                
                ForEach(IntervalLabelChoice.allCases, id: \.self) {key in
                    GridRow {
                        key.image
                            .gridCellAnchor(.center)
                            .foregroundColor(.white)
                        Toggle(key.label,
                               isOn: notationalContext.intervalBinding(for: instrumentalContext.instrumentChoice, choice: key))
                        .gridCellAnchor(.leading)
                        .tint(Color.gray)
                    }
                    if key == .symbol {
                        Divider()
                    }
                }
            }
            .padding(10)
        }
    }
}
