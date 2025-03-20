import SwiftUI

/// Touch-oriented musical keyboard
public struct InstrumentView: Identifiable, View {
    @EnvironmentObject public var instrumentalContext: InstrumentalContext
    @EnvironmentObject public var tonalContext: TonalContext

    public let id = UUID()
    public init() { }
    public var body: some View {
        ZStack {
            switch instrumentalContext.instrumentChoice {
            case .tonnetz:
                TonnetzView(
                    tonnetz: instrumentalContext.instrument as! Tonnetz
                )
            case .linear:
                LinearView(
                    linear: instrumentalContext.instrument as! Linear
                )
            case .diamanti:
                DiamantiView(
                    diamanti: instrumentalContext.instrument as! Diamanti
                )
            case .piano:
                PianoView(
                    piano: instrumentalContext.instrument as! Piano
                )
            case .violin:
                StringsView(
                    stringInstrument: instrumentalContext.instrument as! Violin
                )
            case .cello:
                StringsView(
                    stringInstrument: instrumentalContext.instrument as! Cello
                )
            case .bass:
                StringsView(
                    stringInstrument: instrumentalContext.instrument as! Bass
                )
            case .banjo:
                StringsView(
                    stringInstrument: instrumentalContext.instrument as! Banjo
                )
            case .guitar:
                StringsView(
                    stringInstrument: instrumentalContext.instrument as! Guitar
                )
            default:
                EmptyView()
            }
            
            KeyboardKeyMultitouchView { touches in
                instrumentalContext.setPitchLocations(pitchLocations: touches, tonalContext: tonalContext)
            }
            
        }
        .coordinateSpace(name: "InstrumentSpace")
        .onPreferenceChange(PitchRectsKey.self) { keyRectInfos in
            Task { @MainActor in
                instrumentalContext.pitchRectInfos = keyRectInfos
            }
        }
    }
}
