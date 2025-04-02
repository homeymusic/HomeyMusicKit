import SwiftUI

@Observable
public final class InstrumentalContext {
    @ObservationIgnored
    @AppStorage("instrumentChoice")
    private var instrumentChoiceRaw: Int = Int(InstrumentChoice.default.rawValue)
    
    @ObservationIgnored
    @AppStorage("stringInstrumentChoice")
    private var stringInstrumentChoiceRaw: Int = Int(InstrumentChoice.defaultStringInstrumentChoice.rawValue)
    
    @ObservationIgnored
    @AppStorage("latching")
    public var latchingRaw: Bool = false
    
    public func toggleLatching(with tonalContext: TonalContext) {
        latching.toggle()
        if !latching {
            tonalContext.deactivateAllPitches()
        }
    }
    
    public var instrumentChoice: InstrumentChoice = InstrumentChoice.default {
        didSet {
            instrumentChoiceRaw = Int(instrumentChoice.rawValue)
            // Keep stringInstrumentChoice in sync if the instrument is a string.
            if instrumentChoice.isStringInstrument {
                stringInstrumentChoice = instrumentChoice
                stringInstrumentChoiceRaw = Int(instrumentChoice.rawValue)
            }
        }
    }
    
    public var stringInstrumentChoice: InstrumentChoice  = InstrumentChoice.defaultStringInstrumentChoice {
        didSet {
            stringInstrumentChoiceRaw = Int(stringInstrumentChoice.rawValue)
        }
    }
    
    public var latching: Bool = false {
        didSet {
            latchingRaw = latching
        }
    }
    
    var pitchRectInfos: [InstrumentCoordinate: PitchRectInfo] = [:]
    
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
            case .modePicker:
                mapping[instrumentChoice] = ModePicker()
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
    
//    @MainActor
    public init() {
        // Initialize published properties from the persisted raw values.
        self.instrumentChoice = InstrumentChoice(rawValue: MIDIChannel(instrumentChoiceRaw)) ?? InstrumentChoice.default
        self.stringInstrumentChoice = InstrumentChoice(rawValue: MIDIChannel(stringInstrumentChoiceRaw)) ?? InstrumentChoice.defaultStringInstrumentChoice
        self.latching = latchingRaw
    }
    
    public var instruments: [InstrumentChoice] {
        InstrumentChoice.keyboardInstruments + [self.stringInstrumentChoice]
    }
    
    private var latchingTouchedPitches = Set<Pitch>()
    
    public func setPitchLocations(
        pitchLocations: [CGPoint],
        tonalContext: TonalContext,
        instrument: Instrument
    ) {
        var touchedPitches = Set<Pitch>()
        
        // Process the touch locations and determine which keys are touched
        for location in pitchLocations {
            var pitch: Pitch?
            var highestZindex = -1
            
            // Find the pitch at this location with the highest Z-index
            for pitchRectangle in pitchRectInfos.values where pitchRectangle.contains(location) {
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
    
    public func setTonicLocations(tonicLocations: [CGPoint], tonalContext: TonalContext,
                                  notationalTonicContext: NotationalTonicContext) {
        for location in tonicLocations {
            var tonicPitch: Pitch?
            for info in tonicRectInfos where info.rect.contains(location) {
                if tonicPitch == nil {
                    tonicPitch = tonalContext.pitch(for: info.midiNoteNumber)
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    
                    updateTonic(tonicPitch: t, tonalContext: tonalContext,
                                notationalTonicContext: notationalTonicContext)
                    
                    isTonicLocked = true
                    
                }
            }
        }
        
        if tonicLocations.isEmpty {
            isTonicLocked = false
        }
    }
    
    public func resetTonalContext(tonalContext: TonalContext) {
        tonalContext.tonicPitch = tonalContext.pitch(for: Pitch.defaultTonicMIDINoteNumber)
        tonalContext.mode = .default
        tonalContext.pitchDirection = .default
        buzz()
    }

    public func updateTonic(tonicPitch: Pitch, tonalContext: TonalContext, notationalTonicContext: NotationalTonicContext) {
        buzz()

        if tonalContext.pitchDirection == .mixed {
            if tonicPitch == tonalContext.tonicPitch {
                tonalContext.shiftDownOneOctave()
                buzz()
                return
            } else if tonicPitch.isOctave(relativeTo: tonalContext.tonicPitch) {
                tonalContext.shiftUpOneOctave()
                return
            }
        }
        
        if tonicPitch.isOctave(relativeTo: tonalContext.tonicPitch) {
            if tonicPitch.midiNote.number > tonalContext.tonicPitch.midiNote.number {
                tonalContext.pitchDirection = .downward
            } else {
                tonalContext.pitchDirection = .upward
            }
            tonalContext.tonicPitch = tonicPitch
            return
        } else {
            if notationalTonicContext.showModePicker {
                let newMode: Mode = Mode(
                    rawValue: modulo(
                        tonalContext.mode.rawValue + Int(tonicPitch.distance(from: tonalContext.tonicPitch)), 12
                    ))!
                
                tonalContext.tonicPitch = tonicPitch

                if newMode != tonalContext.mode {
                    let oldDirection = tonalContext.mode.pitchDirection
                    let newDirection = newMode.pitchDirection
                    switch (oldDirection, newDirection) {
                    case (.upward, .downward):
                        break
                    case (.downward, .upward):
                        break
                    case (.upward, .upward):
                        break
                    case (.mixed, .downward):
                        tonalContext.shiftDownOneOctave()
                        break
                    case (.mixed, .upward):
                        tonalContext.shiftUpOneOctave()
                        break
                    default:
                        break
                    }

                    tonalContext.mode = newMode
                    tonalContext.pitchDirection = newMode.pitchDirection
                }
            } else {
                tonalContext.tonicPitch = tonicPitch
            }
            return
        }
    }
    
    var modeRectInfos: [ModeRectInfo] = []
    private var isModeLocked = false
    
    public func setModeLocations(modeLocations: [CGPoint], tonalContext: TonalContext,
                                 notationalTonicContext: NotationalTonicContext) {
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
                    let oldDirection = tonalContext.mode.pitchDirection
                    let newDirection = m.pitchDirection
                    switch (oldDirection, newDirection) {
                    case (.mixed, .downward):
                        tonalContext.shiftUpOneOctave()
                    case (.upward, .downward):
                        tonalContext.shiftUpOneOctave()
                    case (.downward, .upward):
                        tonalContext.shiftDownOneOctave()
                    case (.downward, .mixed):
                        tonalContext.shiftDownOneOctave()
                    default:
                        break
                    }
                    updateMode(m, tonalContext: tonalContext, notationalTonicContext: notationalTonicContext)
                    isModeLocked = true
                }
            }
        }
        
        if modeLocations.isEmpty {
            isModeLocked = false
        }
    }
    
    private func updateMode(_ newMode: Mode,
                            tonalContext: TonalContext,
                            notationalTonicContext: NotationalTonicContext) {
        
        if newMode != tonalContext.mode && notationalTonicContext.showModePicker {
            tonalContext.mode = newMode
            if tonalContext.pitchDirection != newMode.pitchDirection {
                tonalContext.pitchDirection = newMode.pitchDirection
            }
            buzz()
        }
    }
    
}
