import SwiftUI
import SwiftData

struct ColorPalettePreviewView: View {
    @Environment(InstrumentalContext.self) var instrumentalContext
    
    var body: some View {
        let colorPalette = IntervalColorPalette.homey
        GeometryReader { geometry in
            List {
                Section("Preview") {
                    Grid {
                        if colorPalette is IntervalColorPalette {
                            intervalPreview
                        } else if colorPalette is PitchColorPalette {
                            pitchPreview
                        } else {
                            EmptyView()
                        }                        
                    }
                    .frame(height: geometry.size.height * 0.8)
                }
                .listRowBackground(Color.black)
            }
        }
    }
    
    // MARK: - Interval Preview
    private var intervalPreview: some View {
        Group {
            GridRow {
                Text("MINOR")
                Text("NEUTRAL")
                Text("MAJOR")
            }
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .minor,    consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true, isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: true, isOutlined: true)
            }
            GridRow {
                VStack {
                    Text("ACTIVATED")
                    Text("MINOR")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("NEUTRAL")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("MAJOR")
                }
            }
        }
        .font(.caption2).foregroundColor(.systemGray)
            .gridCellAnchor(.center)
    }
    
    // MARK: - Pitch Preview
    private var pitchPreview: some View {
        Group {
            GridRow {
                Text("NATURAL")
                Text("ACCIDENTAL")
            }
            GridRow {
                PitchCellPreview(isActivated: false, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: false, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
            }
            GridRow {
                PitchCellPreview(isActivated: true, majorMinor: .neutral, consonanceDissonance: .tonic,     isNatural: true,  isOutlined: true)
                PitchCellPreview(isActivated: true, majorMinor: .major,   consonanceDissonance: .consonant, isNatural: false, isOutlined: true)
            }
            GridRow {
                VStack {
                    Text("ACTIVATED")
                    Text("NATURAL")
                }
                VStack {
                    Text("ACTIVATED")
                    Text("ACCIDENTAL")
                }
            }
        }
        .font(.caption2).foregroundColor(.systemGray)
            .gridCellAnchor(.center)
    }
}

