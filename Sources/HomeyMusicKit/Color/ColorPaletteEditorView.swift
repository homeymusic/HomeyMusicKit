import SwiftUI
import SwiftData

struct ColorPaletteEditorView: View {
    @Environment(NotationalContext.self) var notationalContext
    
    var body: some View {
        let colorPalette = notationalContext.colorPalette
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
                    .onSubmit {
                        intervalColorPalette.name = intervalColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
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

            if !intervalColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                         showDeleteConfirmation = true
                     }
                }
            }
        }
        .alert(
            "Confirm Deletion",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice]
                    = IntervalColorPalette.homey
                notationalContext.colorPalette
                    = IntervalColorPalette.homey
                modelContext.delete(intervalColorPalette)
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
                    .onSubmit {
                        pitchColorPalette.name = pitchColorPalette.name.trimmingCharacters(in: .whitespacesAndNewlines)
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

            if !pitchColorPalette.isSystemPalette {
                Section("Danger Zone") {
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
        }
        .alert(
            "Confirm Deletion",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                notationalContext.colorPalettes[instrumentalContext.instrumentChoice]
                    = PitchColorPalette.ivory
                notationalContext.colorPalette
                    = PitchColorPalette.ivory
                modelContext.delete(pitchColorPalette)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this palette?")
        }

    }
}
