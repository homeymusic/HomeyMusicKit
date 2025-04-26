import SwiftUI
import SwiftData

struct NotationPopoverView: View {
    @Environment(\.modelContext)            private var modelContext
    @Environment(TonalContext.self)         private var tonalContext
    @Environment(InstrumentalContext.self)  private var instrumentalContext

    private var instrument: any Instrument {
        instrumentalContext.instrument
    }

    var body: some View {
        @Bindable var tonalContext = tonalContext
        VStack(spacing: 0) {
            Grid {
                // — INTERVAL LABELS —
                ForEach(IntervalLabelChoice.allCases, id: \.self) { choice in
                    if choice == .symbol {
                        Divider()
                    }
                    GridRow {
                        choice.image
                            .gridCellAnchor(.center)
                            .foregroundColor(.white)
                        Toggle(choice.label, isOn: intervalBinding(for: choice))
                            .gridCellAnchor(.leading)
                            .tint(.gray)
                    }
                }

                Divider()

                // — PITCH LABELS —
                ForEach(PitchLabelChoice.allCases, id: \.self) { choice in
                    // skip any special ones if you like
                    if choice != .accidentals {
                        GridRow {
                            choice.image
                                .gridCellAnchor(.center)
                                .foregroundColor(.white)
                            Toggle(choice.label, isOn: pitchBinding(for: choice))
                                .gridCellAnchor(.leading)
                                .tint(.gray)
                        }

                        // if you need the “fixed Do” submenu
                        if choice == .fixedDo {
                            // Accidentals‐picker
                            GridRow {
                                choice.image
                                    .gridCellAnchor(.center)
                                    .foregroundColor(.white)
                                Picker("", selection: $tonalContext.accidental) {
                                    ForEach(Accidental.displayCases) { acc in
                                        Text(acc.icon).tag(acc)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
    }

    // MARK: – Helpers to bind each choice to its array membership

    private func pitchBinding(for choice: PitchLabelChoice) -> Binding<Bool> {
        Binding(
            get: {
                instrument.pitchLabelChoices.contains(choice)
            },
            set: { isOn in
                try? modelContext.transaction {
                    if isOn {
                        if !instrument.pitchLabelChoices.contains(choice) {
                            instrument.pitchLabelChoices.append(choice)
                        }
                    } else {
                        instrument.pitchLabelChoices.removeAll { $0 == choice }
                    }
                }
            }
        )
    }

    private func intervalBinding(for choice: IntervalLabelChoice) -> Binding<Bool> {
        Binding(
            get: {
                instrument.intervalLabelChoices.contains(choice)
            },
            set: { isOn in
                try? modelContext.transaction {
                    if isOn {
                        if !instrument.intervalLabelChoices.contains(choice) {
                            instrument.intervalLabelChoices.append(choice)
                        }
                    } else {
                        instrument.intervalLabelChoices.removeAll { $0 == choice }
                    }
                }
            }
        )
    }
}
