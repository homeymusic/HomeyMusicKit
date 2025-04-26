import SwiftUI

/// Touch-oriented musical keyboard
public struct InstrumentView: Identifiable, View {
    @Environment(TonalContext.self) public var tonalContext
    
    public let id = UUID()
    
    private let instrument: any Instrument
    
    public init(_ instrument: any Instrument) {
        self.instrument = instrument
    }
    
    public var body: some View {
        ZStack {
            switch instrument {
            case let tonnetz as Tonnetz:
                TonnetzView(tonnetz: tonnetz)
                
            case let linear as Linear:
                LinearView(linear: linear)
                
            case let diamanti as Diamanti:
                DiamantiView(diamanti: diamanti)
                
            case let piano as Piano:
                PianoView(piano: piano)
                
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
                instrument.setPitchLocations(
                    pitchLocations: touches,
                    tonalContext: tonalContext)
            }
            
        }
        .onPreferenceChange(OverlayCellKey.self) { pitchOverlayCell in
            Task { @MainActor in
                instrument.pitchOverlayCells = pitchOverlayCell
            }
        }
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }
    
}
