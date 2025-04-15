import SwiftUI
import SwiftData

struct ColorPaletteEditorView: View {
    @Environment(NotationalContext.self) var notationalContext
    @Environment(InstrumentalContext.self) var instrumentalContext

    var body: some View {
        let colorPalette = notationalContext.colorPalette(for: instrumentalContext.instrumentChoice)
        if colorPalette is IntervalColorPalette {
            IntervalColorPaletteEditorView(intervalColorPalette: colorPalette as! IntervalColorPalette)
        } else if colorPalette is PitchColorPalette {
            PitchColorPaletteEditorView(pitchColorPalette: colorPalette as! PitchColorPalette)
        }
    }
}

struct IntervalColorPaletteEditorView: View {
    @Bindable var intervalColorPalette: IntervalColorPalette
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

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
                notationalContext.replaceDeletedPalette(intervalColorPalette, with: IntervalColorPalette.homey)
                modelContext.delete(intervalColorPalette)
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
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isNameFieldFocused: Bool
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext

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
                notationalContext.replaceDeletedPalette(pitchColorPalette, with: PitchColorPalette.ivory)
                modelContext.delete(pitchColorPalette)
                buzz()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this palette?")
        }

    }
}
