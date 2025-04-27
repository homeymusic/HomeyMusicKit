import SwiftUI

/// Touch-oriented musical keyboard
public struct InstrumentView: Identifiable, View {
    @Environment(TonalContext.self) public var tonalContext
    
    public let id = UUID()
    
    private let instrument: any Instrument
    
    @State public var pitchOverlayCells:      [InstrumentCoordinate: OverlayCell] = [:]
    @State private var latchingTouchedPitches: Set<Pitch>                          = []
    
    public init(_ instrument: any Instrument) {
        self.instrument = instrument
    }
    
    public var body: some View {
        ZStack {
            switch instrument {
            case let tonnetz as Tonnetz:
                TonnetzView(tonnetz: tonnetz, pitchOverlayCells: $pitchOverlayCells)
                
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
                self.setPitchLocations(
                    pitchLocations: touches,
                    tonalContext: tonalContext,
                    instrument: instrument
                )
            }
            
        }
        .onChange(of: instrument.latching) {
            if !instrument.latching {
                latchingTouchedPitches.removeAll()
                tonalContext.deactivateAllPitches()
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { pitchOverlayCell in
            Task { @MainActor in
                self.pitchOverlayCells = pitchOverlayCell
            }
        }
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }
    
    func setPitchLocations(
        pitchLocations: [CGPoint],
        tonalContext: TonalContext,
        instrument: any Instrument
    ) {
        var touchedPitches = Set<Pitch>()
        
        // 1) Find which pitches your overlay cells hit, picking topmost by zIndex
        for location in pitchLocations {
            var picked: Pitch?
            var highestZ = -1
            
            for cell in pitchOverlayCells.values where cell.contains(location) {
                if picked == nil || cell.zIndex > highestZ {
                    picked   = tonalContext.pitch(
                        for: MIDINoteNumber(cell.identifier)
                    )
                    highestZ = cell.zIndex
                }
            }
            
            guard let p = picked else { continue }
            touchedPitches.insert(p)
            
            // 2) Activate/deactivate based on latching vs non-latching
            if instrument.latching {
                if !latchingTouchedPitches.contains(p) {
                    latchingTouchedPitches.insert(p)
                    
                    if instrument.instrumentChoice == .tonnetz {
                        // special Tonnetz behavior
                        if p.pitchClass.isActivated(in: tonalContext.activatedPitches) {
                            p.pitchClass.deactivate(in: tonalContext.activatedPitches)
                        } else {
                            p.activate()
                        }
                    } else {
                        // simple toggle
                        p.isActivated ? p.deactivate() : p.activate()
                    }
                }
            } else {
                if !p.isActivated {
                    p.activate()
                }
            }
        }
        
        // 3) On non-latching, release any pitches no longer touched
        if !instrument.latching {
            for pitch in tonalContext.activatedPitches {
                if !touchedPitches.contains(pitch) {
                    pitch.deactivate()
                }
            }
        }
        
        // 4) When all touches lifted, clear the latch history
        if pitchLocations.isEmpty {
            latchingTouchedPitches.removeAll()
        }
    }
    
}
