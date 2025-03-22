import SwiftUI

final public class InstrumentalContext: ObservableObject {
    @AppStorage("instrumentChoice") private var instrumentChoiceRaw: Int = Int(InstrumentChoice.default.rawValue)
    @AppStorage("stringInstrumentChoice") private var stringInstrumentChoiceRaw: Int = Int(InstrumentChoice.defaultStringInstrumentChoice.rawValue)
    @AppStorage("latching") public var latching: Bool = false
    
    @Published public var instrumentChoice: InstrumentChoice = InstrumentChoice.default {
        didSet {
            instrumentChoiceRaw = Int(instrumentChoice.rawValue)
            // Keep stringInstrumentChoice in sync if the instrument is a string.
            if instrumentChoice.isStringInstrument {
                stringInstrumentChoice = instrumentChoice
                stringInstrumentChoiceRaw = Int(instrumentChoice.rawValue)
            }
        }
    }
    
    @Published public var stringInstrumentChoice: InstrumentChoice  = InstrumentChoice.defaultStringInstrumentChoice {
        didSet {
            stringInstrumentChoiceRaw = Int(stringInstrumentChoice.rawValue)
        }
    }
    
    @Published var pitchRectInfos: [InstrumentCoordinate: PitchRectInfo] = [:]
    
    public func toggleLatching(with tonalContext: TonalContext) {
        latching.toggle()
        if !latching {
            tonalContext.deactivateAllPitches()
        }
    }
    
    @MainActor
    private(set) var instrumentByChoice: [InstrumentChoice: Instrument] = {
        var mapping: [InstrumentChoice: Instrument] = [:]
        InstrumentChoice.allCases.forEach { instrumentChoice in
            switch instrumentChoice {
            case .linear:
                mapping[instrumentChoice] = Linear()
            case .tonnetz:
                mapping[instrumentChoice] = Tonnetz()
            case .diamanti:
                mapping[instrumentChoice] = Diamanti()
            case .piano:
                mapping[instrumentChoice] = Piano()
            case .violin:
                mapping[instrumentChoice] = Violin()
            case .cello:
                mapping[instrumentChoice] = Cello()
            case .bass:
                mapping[instrumentChoice] = Bass()
            case .banjo:
                mapping[instrumentChoice] = Banjo()
            case .guitar:
                mapping[instrumentChoice] = Guitar()
            case .tonicPicker:
                mapping[instrumentChoice] = TonicPicker()
            }
        }
        return mapping
    }()
    
    @MainActor
    public var instrument: Instrument {
        guard let inst = instrumentByChoice[instrumentChoice] else {
            fatalError("No instrument instance found for \(instrumentChoice)")
        }
        return inst
    }
    
    @MainActor
    public var keyboardInstrument: KeyboardInstrument {
        guard let inst = instrumentByChoice[instrumentChoice] as? KeyboardInstrument else {
            fatalError("No keyboard instrument instance found for \(instrumentChoice)")
        }
        return inst
    }
    
    @MainActor
    public init() {
        // Initialize published properties from the persisted raw values.
        self.instrumentChoice = InstrumentChoice(rawValue: MIDIChannel(instrumentChoiceRaw)) ?? InstrumentChoice.default
        self.stringInstrumentChoice = InstrumentChoice(rawValue: MIDIChannel(stringInstrumentChoiceRaw)) ?? InstrumentChoice.defaultStringInstrumentChoice
    }
    
    public var instruments: [InstrumentChoice] {
        InstrumentChoice.keyboardInstruments + [self.stringInstrumentChoice]
    }
    
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
            for pitchRectangle in pitchRectInfos.values where pitchRectangle.rect.contains(location) {
                if pitch == nil || pitchRectangle.zIndex > highestZindex {
                    pitch = tonalContext.pitch(for: pitchRectangle.midiNoteNumber)
                    highestZindex = pitchRectangle.zIndex
                }
            }
            
            if let p = pitch {
                touchedPitches.insert(p)
                
                if latching {
                    if !latchingTouchedPitches.contains(p) {
                        latchingTouchedPitches.insert(p)
                        
                        if instrumentChoice == .tonnetz {
                            if p.pitchClass.isActivated(in: tonalContext.activatedPitches) {
                                p.pitchClass.deactivate(in: tonalContext.activatedPitches)
                            } else {
                                p.activate()
                            }
                        } else {
                            // Toggle pitch activation
                            if p.isActivated {
                                p.deactivate()
                            } else {
                                p.activate()
                            }
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
                    tonicPitch = tonalContext.pitch(for: info.midiNoteNumber)
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    
                    updateTonic(tonicPitch: t, tonalContext: tonalContext)
                    
                    isTonicLocked = true
                    
                }
            }
        }
        
        if tonicLocations.isEmpty {
            isTonicLocked = false
        }
    }
    
    public func resetTonalContext(tonalContext: TonalContext) {
        updateTonic(
            tonicPitch: tonalContext.pitch(for: Pitch.defaultTonicMIDINoteNumber),
            tonalContext: tonalContext
        )
        tonalContext.mode = .default
        tonalContext.pitchDirection = .default
    }    

    public func updateTonic(tonicPitch: Pitch, tonalContext: TonalContext) {
        if tonicPitch.isOctave(relativeTo: tonalContext.tonicPitch) {
            if tonicPitch.midiNote.number > tonalContext.tonicPitch.midiNote.number {
                tonalContext.pitchDirection = .downward
            } else {
                tonalContext.pitchDirection = .upward
            }
        }
        
        let newMode: Mode = Mode(
            rawValue: modulo(
                tonalContext.mode.rawValue + Int(tonicPitch.distance(from: tonalContext.tonicPitch)), 12
            ))!
        
        if tonalContext.mode != newMode {
            if newMode.pitchDirection != .mixed {
                tonalContext.pitchDirection = newMode.pitchDirection
            }
            tonalContext.mode = newMode
        }
                            
        tonalContext.tonicPitch = tonicPitch
        
        buzz()
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
            buzz()
        }
    }
    
    @ViewBuilder
    public func debugRectOverlay() -> some View {
        ForEach(Array(self.pitchRectInfos), id: \.key) { (_, info) in
            // e.g. red for zIndex=1, blue for zIndex=0
            let color: Color = (info.zIndex == 1) ? .red : .blue
            
            Rectangle()
                .stroke(color, lineWidth: 2)
                .frame(width: info.rect.width, height: info.rect.height)
                .position(x: info.rect.midX, y: info.rect.midY)
        }
    }
    
    @ViewBuilder
    public func debugTonicRectOverlay() -> some View {
        ForEach(Array(self.tonicRectInfos.enumerated()), id: \.offset) { index, info in
            let color: Color = (info.zIndex == 1) ? .red : .blue
            
            Rectangle()
                .stroke(color, lineWidth: 2)
                .frame(width: info.rect.width, height: info.rect.height)
                .position(x: info.rect.midX, y: info.rect.midY)
        }
    }
    
    @ViewBuilder
    public func debugModeRectOverlay() -> some View {
        ForEach(Array(self.modeRectInfos.enumerated()), id: \.offset) { index, info in
            let color: Color = .blue
            
            Rectangle()
                .stroke(color, lineWidth: 2)
                .frame(width: info.rect.width, height: info.rect.height)
                .position(x: info.rect.midX, y: info.rect.midY)
        }
    }

}
