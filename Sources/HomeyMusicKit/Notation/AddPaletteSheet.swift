import SwiftUI
import SwiftData

struct AddPaletteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    
    let initialPalette: ColorPalette
    let onSave: (ColorPalette) -> Void

    // Local @State for user inputs
    @State private var paletteName: String
    @State private var palettepitchPosition: Int
    @State private var chosenType: ColorPaletteType

    // Movable defaults
    @State private var baseColor: Color
    @State private var majorColor: Color
    @State private var neutralColor: Color
    @State private var minorColor: Color

    // Fixed defaults
    @State private var accidentalColor: Color
    @State private var naturalColor: Color
    @State private var outlineColor: Color

    // Init: copy fields from the initialPalette into local @State
    init(initialPalette: ColorPalette, onSave: @escaping (ColorPalette) -> Void) {
        self.initialPalette = initialPalette
        self.onSave = onSave
        
        _paletteName      = State(initialValue: initialPalette.name)
        _palettepitchPosition  = State(initialValue: initialPalette.pitchPosition!)
        _chosenType       = State(initialValue: initialPalette.paletteType)
        
        _baseColor        = State(initialValue: initialPalette.baseColor)
        _majorColor       = State(initialValue: initialPalette.majorColor)
        _neutralColor     = State(initialValue: initialPalette.neutralColor)
        _minorColor       = State(initialValue: initialPalette.minorColor)
        _accidentalColor  = State(initialValue: initialPalette.accidentalColor)
        _naturalColor     = State(initialValue: initialPalette.naturalColor)
        _outlineColor     = State(initialValue: initialPalette.outlineColor)
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                ColorPaletteTypeSelectorView(chosenType: $chosenType)
                    .frame(maxWidth: .infinity, alignment: .center)

                // NAME
                Section(header: Text("Palette Name")) {
                    TextField("Name", text: $paletteName)
                }

                // MOVABLE COLORS (only if chosenType == .movable)
                if chosenType == .interval {
                    Section {
                        ColorPicker("Base Color", selection: $baseColor)
                        ColorPicker("Major Color", selection: $majorColor)
                        ColorPicker("Neutral Color", selection: $neutralColor)
                        ColorPicker("Minor Color", selection: $minorColor)
                    }
                }
                // FIXED COLORS (only if chosenType == .fixed)
                else {
                    Section {
                        ColorPicker("Accidental Color", selection: $accidentalColor)
                        ColorPicker("Natural Color", selection: $naturalColor)
                        ColorPicker("Outline Color", selection: $outlineColor)
                    }
                }

                // ACTION BUTTONS
                Section {
                    HStack {
                        Spacer()
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            Label("Cancel", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)

                        Spacer()
                        Button {
                            savePalette()
                        } label: {
                            Label("Save", systemImage: "checkmark.circle")
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle("Create Custom Palette")
        }
    }

    private func savePalette() {
        guard !paletteName.isEmpty else { return }

        let newPalette = ColorPalette(
            name: paletteName,
            pitchPosition: palettepitchPosition,
            paletteType: chosenType,
            isSystemPalette: false,
            baseRGBAColor:       (chosenType == .interval) ? RGBAColor(baseColor)       : nil,
            majorRGBAColor:      (chosenType == .interval) ? RGBAColor(majorColor)      : nil,
            neutralRGBAColor:    (chosenType == .interval) ? RGBAColor(neutralColor)    : nil,
            minorRGBAColor:      (chosenType == .interval) ? RGBAColor(minorColor)      : nil,
            accidentalRGBAColor: (chosenType == .pitch)   ? RGBAColor(accidentalColor) : nil,
            naturalRGBAColor:    (chosenType == .pitch)   ? RGBAColor(naturalColor)    : nil,
            outlineRGBAColor:    (chosenType == .pitch)   ? RGBAColor(outlineColor)    : nil
        )

        // Insert and callback
        modelContext.insert(newPalette)
        onSave(newPalette)
        dismiss()
    }
}

import SwiftUI

/// A custom "segmented" control for choosing between
/// `.movable` or `.fixed` palette types.
struct ColorPaletteTypeSelectorView: View {
    @Binding var chosenType: ColorPaletteType

    var body: some View {
        // A horizontal stack that mimics a segmented control
        HStack(spacing: 0) {
            // First segment: .movable
            segmentButton(for: .interval, icon: "swatchpalette")
            
            // Second segment: .fixed
            segmentButton(for: .pitch, icon: "swatchpalette.fill")
        }
        .background(Color.systemGray6) // the "bar" background
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    /// A single "segment" in our custom control.
    private func segmentButton(for type: ColorPaletteType, icon: String) -> some View {
        let isSelected = (type == chosenType)
        
        return Button(action: {
            // Only set if we're not already that type
            if !isSelected {
                chosenType = type
            }
        }) {
            // Combine an icon + text in one row
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(type.rawValue.capitalized)
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(minWidth: 80) // force a bit of width
            .background(isSelected ? Color.systemGray2 : Color.clear)
        }
        .disabled(isSelected) // disable tap if it's already selected
    }

}
