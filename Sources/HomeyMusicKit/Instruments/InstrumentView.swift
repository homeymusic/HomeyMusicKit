import SwiftUI

/// Touch-oriented musical keyboard
public struct InstrumentView: Identifiable, View {
    @Environment(InstrumentalContext.self) public var instrumentalContext
    @Environment(TonalContext.self) public var tonalContext

    public let id = UUID()
    
    private let instrument: Instrument  // or whatever the protocol/base class is

    public init(_ instrument: Instrument) {
        self.instrument = instrument
    }

    public var body: some View {
        ZStack {
            switch instrument {
            case let tonnetz as Tonnetz:
                TonnetzView(tonnetz: tonnetz)

            case let linear as Linear:
                withConditionalAspect(
                    LinearView(linear: linear)
                )

            case let diamanti as Diamanti:
                withConditionalAspect(
                    DiamantiView(diamanti: diamanti)
                )

            case let piano as Piano:
                withConditionalAspect(
                    PianoView(piano: piano)
                )

            case let violin as Violin:
                StringsView(stringInstrument: violin)

            case let cello as Cello:
                StringsView(stringInstrument: cello)

            case let bass as Bass:
                StringsView(stringInstrument: bass)

            case let banjo as Banjo:
                StringsView(stringInstrument: banjo)

            case let guitar as Guitar:
                StringsView(stringInstrument: guitar)

            default:
                EmptyView()
            }

            MultiTouchOverlayView { touches in
                instrumentalContext.setPitchLocations(
                    pitchLocations: touches,
                    tonalContext: tonalContext,
                    instrument: instrument)
            }
            
        }
        .onPreferenceChange(OverlayCellKey.self) { pitchOverlayCell in
            Task { @MainActor in
                instrumentalContext.pitchOverlayCells = pitchOverlayCell
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
