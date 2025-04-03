import SwiftUI

/// Touch-oriented musical keyboard
public struct InstrumentView: Identifiable, View {
    @Environment(InstrumentalContext.self) public var instrumentalContext
    @Environment(TonalContext.self) public var tonalContext

    public let id = UUID()
    public init() { }
    
    public var body: some View {
        ZStack {
            switch instrumentalContext.instrumentChoice {
            case .tonnetz:
                TonnetzView(tonnetz: instrumentalContext.instrument as! Tonnetz)
            case .linear:
                withConditionalAspect(
                    LinearView(linear: instrumentalContext.instrument as! Linear)
                )
            case .diamanti:
                withConditionalAspect(
                    DiamantiView(diamanti: instrumentalContext.instrument as! Diamanti)
                )
            case .piano:
                withConditionalAspect(
                    PianoView(piano: instrumentalContext.instrument as! Piano)
                )
            case .violin:
                StringsView(stringInstrument: instrumentalContext.instrument as! Violin)
            case .cello:
                StringsView(stringInstrument: instrumentalContext.instrument as! Cello)
            case .bass:
                StringsView(stringInstrument: instrumentalContext.instrument as! Bass)
            case .banjo:
                StringsView(stringInstrument: instrumentalContext.instrument as! Banjo)
            case .guitar:
                StringsView(stringInstrument: instrumentalContext.instrument as! Guitar)
            default:
                EmptyView()
            }
            
            MultiTouchOverlayView { touches in
                instrumentalContext.setPitchLocations(
                    pitchLocations: touches,
                    tonalContext: tonalContext,
                    instrument: instrumentalContext.instrument)
            }
            
        }
        .onPreferenceChange(OverlayCellKey.self) { keyRectInfos in
            Task { @MainActor in
                instrumentalContext.pitchOverlayCells = keyRectInfos
            }
        }
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }
    
    /// Condition to determine whether the aspect ratio should be applied.
    private var shouldApplyAspectRatio: Bool {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad &&
        instrumentalContext.keyboardInstrument.rows == 0
#elseif os(macOS)
        instrumentalContext.keyboardInstrument.rows == 0
#endif
    }
    
    /// Helper that conditionally applies an aspect ratio modifier to a view.
    private func withConditionalAspect<T: View>(_ view: T) -> some View {
        view.if(shouldApplyAspectRatio) { view in
            view.aspectRatio(4.0, contentMode: .fit)
        }
    }
    
}

// Custom view extension to conditionally apply a modifier.
extension View {
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
