import SwiftUI

final public class InstrumentalContext: ObservableObject {
    @Published public var instrumentChoice: InstrumentChoice {
        didSet {
            if instrumentChoice.isStringInstrument {
                stringInstrumentType = instrumentChoice
            }
        }
    }
    @Published public var stringInstrumentType: InstrumentChoice
    
    @Published public var latching: Bool
    
    public func toggleLatching(with tonalContext: TonalContext) {
        latching.toggle()
        if !latching {
            tonalContext.deactivateAllPitches()
        }
    }
    
    @MainActor
    private(set) var instrumentByType: [InstrumentChoice: Instrument] = {
        var mapping: [InstrumentChoice: Instrument] = [:]
        InstrumentChoice.allCases.forEach { instrumentType in
            switch instrumentType {
            case .linear:
                mapping[instrumentType] = Linear()
            case .tonnetz:
                mapping[instrumentType] = Tonnetz()
            case .diamanti:
                mapping[instrumentType] = Diamanti()
            case .piano:
                mapping[instrumentType] = Piano()
            case .violin:
                mapping[instrumentType] = Violin()
            case .cello:
                mapping[instrumentType] = Cello()
            case .bass:
                mapping[instrumentType] = Bass()
            case .banjo:
                mapping[instrumentType] = Banjo()
            case .guitar:
                mapping[instrumentType] = Guitar()
            case .tonicPicker:
                mapping[instrumentType] = TonicPicker()
            }
        }
        return mapping
    }()
    
    @MainActor
    public var instrument: Instrument {
        guard let inst = instrumentByType[instrumentChoice] else {
            fatalError("No instrument instance found for \(instrumentChoice)")
        }
        return inst
    }
    
    @MainActor
    public var keyboardInstrument: KeyboardInstrument {
        guard let inst = instrumentByType[instrumentChoice] as? KeyboardInstrument else {
            fatalError("No keyboard instrument instance found for \(instrumentChoice)")
        }
        return inst
    }
    
    @MainActor
    public init() {
        self.instrumentChoice = .diamanti
        self.stringInstrumentType = .violin
        self.latching = false
    }
    
    @MainActor
    public var instruments: [InstrumentChoice] {
        InstrumentChoice.keyboardInstruments + [self.stringInstrumentType]
    }
    
    var pitchRectInfos: [PitchRectInfo] = []
    private var latchingTouchedPitches = Set<Pitch>()
    
    public func setPitchLocations(
        pitchLocations: [CGPoint],
        tonalContext: TonalContext
    ) {
        var touchedPitches = Set<Pitch>()
        
        // Process the touch locations and determine which keys are touched
        for location in pitchLocations {
            var pitch: Pitch?
            var highestZindex = -1
            
            // Find the pitch at this location with the highest Z-index
            for info in pitchRectInfos where info.rect.contains(location) {
                if pitch == nil || info.zIndex > highestZindex {
                    pitch = info.pitch
                    highestZindex = info.zIndex
                }
            }
            
            if let p = pitch {
                touchedPitches.insert(p)
                
                if latching {
                    if !latchingTouchedPitches.contains(p) {
                        latchingTouchedPitches.insert(p)
                        // Toggle pitch activation
                        if p.isActivated {
                            p.deactivate()
                        } else {
                            p.activate()
                        }
                    }
                } else {
                    if !p.isActivated {
                        p.activate()
                    }
                }
            }
        }
        
        if !latching {
            for pitch in tonalContext.activatedPitches {
                if !touchedPitches.contains(pitch) {
                    pitch.deactivate()
                }
            }
        }
        
        if pitchLocations.isEmpty {
            latchingTouchedPitches.removeAll()  // Clear for the next interaction
        }
    }
        
    var tonicRectInfos: [TonicRectInfo] = []
    private var isTonicLocked = false
    
    public func setTonicLocations(tonicLocations: [CGPoint], tonalContext: TonalContext) {
        for location in tonicLocations {
            var tonicPitch: Pitch?
            
            for info in tonicRectInfos where info.rect.contains(location) {
                if tonicPitch == nil {
                    tonicPitch = info.pitch
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    tonalContext.tonicPitch = t
                    isTonicLocked = true
                }
            }
        }
        
        if tonicLocations.isEmpty {
            isTonicLocked = false
        }
    }
        
    var modeRectInfos: [ModeRectInfo] = []
    private var isModeLocked = false
    
    public func setModeLocations(modeLocations: [CGPoint], tonalContext: TonalContext) {
        for location in modeLocations {
            var mode: Mode?
            
            // Find the pitch at this location with the highest Z-index
            for info in modeRectInfos where info.rect.contains(location) {
                if mode == nil {
                    mode = info.mode
                }
            }
            
            if let m = mode {
                if !isModeLocked {
                    updateMode(m, tonalContext: tonalContext)
                    isModeLocked = true
                }
            }
        }
        
        if modeLocations.isEmpty {
            isModeLocked = false
        }
    }
    
    private func updateMode(_ newMode: Mode, tonalContext: TonalContext) {
        if newMode != tonalContext.mode {
            // Adjust pitch direction if the new tonic is an octave shift
            tonalContext.mode = newMode
        }
    }
    
    
}
