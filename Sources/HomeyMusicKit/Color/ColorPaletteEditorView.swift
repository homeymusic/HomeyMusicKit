import SwiftUI
import SwiftData

struct ColorPaletteEditorView: View {
    var instrument: MusicalInstrument
    public init(instrument: MusicalInstrument) { self.instrument = instrument}
    
    var body: some View {
        let colorPalette = instrument.colorPalette
        if colorPalette is IntervalColorPalette {
            IntervalColorPaletteEditorView(
                intervalColorPalette: colorPalette as! IntervalColorPalette,
                instrument: instrument
            )
                .id(colorPalette.id)
        } else if colorPalette is PitchColorPalette {
            PitchColorPaletteEditorView(
                pitchColorPalette: colorPalette as! PitchColorPalette,
                instrument: instrument
            )
                .id(colorPalette.id)
        }
    }
}

struct IntervalColorPaletteEditorView: View {
    @Bindable var intervalColorPalette: IntervalColorPalette
    var instrument: MusicalInstrument
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Query(sort: \IntervalColorPalette.position) private var intervalColorPalettes: [IntervalColorPalette]
    
    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $intervalColorPalette.name)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onAppear {
                        if intervalColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isNameFieldFocused = true
                        }
                    }
                    .onSubmit {
                        intervalColorPalette.name = intervalColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if intervalColorPalette.name.isEmpty {
                            intervalColorPalette.name = "Untitled"
                        }
                        isNameFieldFocused = false
                    }
                    .disabled(intervalColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Name")
                    if intervalColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .listRowBackground(Color.systemGray5)

            Section {
                ColorPicker("Minor", selection: $intervalColorPalette.minorColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Neutral", selection: $intervalColorPalette.neutralColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Major", selection: $intervalColorPalette.majorColor)
                    .disabled(intervalColorPalette.isSystemPalette)
                ColorPicker("Background", selection: $intervalColorPalette.cellBackgroundColor)
                    .disabled(intervalColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Interval Colors")
                    if intervalColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .listRowBackground(Color.systemGray5)

            if !intervalColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                         showDeleteConfirmation = true
                     }
                }
                .listRowBackground(Color.systemGray5)
            }
        }
        .alert(
            "Confirm Deletion",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(intervalColorPalette)
                instrument.colorPalette = intervalColorPalettes.first!
                buzz()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this palette?")
        }

    }
}

struct PitchColorPaletteEditorView: View {
    @Bindable var pitchColorPalette: PitchColorPalette
    var instrument: MusicalInstrument
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Query(sort: \PitchColorPalette.position) private var pitchColorPalettes: [PitchColorPalette]

    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $pitchColorPalette.name)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onAppear {
                        if pitchColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            isNameFieldFocused = true
                        }
                    }
                    .onSubmit {
                        pitchColorPalette.name = pitchColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if pitchColorPalette.name.isEmpty {
                            pitchColorPalette.name = "Untitled"
                        }
                        isNameFieldFocused = false
                    }
                    .disabled(pitchColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Name")
                    if pitchColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .listRowBackground(Color.systemGray5)

            Section {
                ColorPicker("Natural", selection: $pitchColorPalette.naturalColor)
                    .disabled(pitchColorPalette.isSystemPalette)
                ColorPicker("Accidental", selection: $pitchColorPalette.accidentalColor)
                    .disabled(pitchColorPalette.isSystemPalette)
                ColorPicker("Outline", selection: $pitchColorPalette.outlineColor)
                    .disabled(pitchColorPalette.isSystemPalette)
            } header: {
                HStack {
                    Text("Pitch Colors")
                    if pitchColorPalette.isSystemPalette {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .listRowBackground(Color.systemGray5)

            if !pitchColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
                .listRowBackground(Color.systemGray5)
            }
        }
        .alert(
            "Confirm Deletion",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(pitchColorPalette)
                instrument.colorPalette = pitchColorPalettes.first!
                buzz()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this palette?")
        }

    }
}
