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
    
    @ObservationIgnored
    @AppStorage("areModeAndTonicLinked")
    public var areModeAndTonicLinkedRaw: Bool = true
    
    public var beforeInstrumentChange: ((InstrumentChoice) -> Void)?
    public var afterInstrumentChange: ((InstrumentChoice) -> Void)?

    public var instrumentChoice: InstrumentChoice = InstrumentChoice.default {
        
        willSet {
            beforeInstrumentChange?(instrumentChoice)
        }
        
        didSet {
            instrumentChoiceRaw = Int(instrumentChoice.rawValue)
            // Keep stringInstrumentChoice in sync if the instrument is a string.
            if instrumentChoice.isStringInstrument {
                stringInstrumentChoice = instrumentChoice
                stringInstrumentChoiceRaw = Int(instrumentChoice.rawValue)
            }
            afterInstrumentChange?(instrumentChoice)
        }
    }
    
    public var stringInstrumentChoice: InstrumentChoice  = InstrumentChoice.defaultStringInstrumentChoice {
        didSet {
            stringInstrumentChoiceRaw = Int(stringInstrumentChoice.rawValue)
        }
    }
    
    public var onLatchingChanged: ((Bool) -> Void)?
    
    public var latching: Bool = false {
        didSet {
            latchingRaw = latching
            onLatchingChanged?(latching)
        }
    }
    
    public var areModeAndTonicLinked: Bool = true {
        didSet {
            areModeAndTonicLinkedRaw = areModeAndTonicLinked
        }
    }
    
    var pitchOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    
    @MainActor
    public var instrumentByChoice: [InstrumentChoice: any Instrument] = {
        var mapping: [InstrumentChoice: any Instrument] = [:]
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
    public var instrument: any Instrument {
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
        self.instrumentChoice = InstrumentChoice(rawValue: instrumentChoiceRaw) ?? InstrumentChoice.default
        self.stringInstrumentChoice = InstrumentChoice(rawValue: stringInstrumentChoiceRaw) ?? InstrumentChoice.defaultStringInstrumentChoice
        self.latching = latchingRaw
        self.areModeAndTonicLinked = areModeAndTonicLinked
    }
    
    public var instruments: [InstrumentChoice] {
        InstrumentChoice.keyboardInstruments + [self.stringInstrumentChoice]
    }
    
    var tonicOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    private var isTonicLocked = false
    
    public func setTonicLocations(tonicLocations: [CGPoint], tonalContext: TonalContext,
                                  notationalTonicContext: NotationalTonicContext) {
        for location in tonicLocations {
            var tonicPitch: Pitch?
            for info in tonicOverlayCells.values where info.rect.contains(location) {
                if tonicPitch == nil {
                    tonicPitch = tonalContext.pitch(for: MIDINoteNumber(info.identifier))
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
            if notationalTonicContext.showModePicker && areModeAndTonicLinked {
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
                        break
                    case (.downward, .downward):
                        break
                    case (.mixed, .upward):
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
    
    var modeOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    private var isModeLocked = false
    
    public func setModeLocations(modeLocations: [CGPoint], tonalContext: TonalContext,
                                 notationalTonicContext: NotationalTonicContext) {
        for location in modeLocations {
            var mode: Mode?
            
            // Find the pitch at this location with the highest Z-index
            for info in modeOverlayCells.values where info.rect.contains(location) {
                if mode == nil {
                    mode = Mode(rawValue: info.identifier)
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
            if notationalTonicContext.showTonicPicker && areModeAndTonicLinked {
                let modeDiff = modulo(newMode.rawValue - tonalContext.mode.rawValue, 12)
                let tonicMIDINumber: Int = Int(tonalContext.tonicMIDI) + modeDiff
                if Pitch.isValid(tonicMIDINumber) {
                    tonalContext.tonicPitch = tonalContext.pitch(for: MIDINoteNumber(tonicMIDINumber))
                } else {
                    fatalError("INVALID TONIC in updateMode in InstrumentalContext!!")
                }
                let oldDirection = tonalContext.mode.pitchDirection
                let newDirection = newMode.pitchDirection
                switch (oldDirection, newDirection) {
                case (.upward, .downward):
                    tonalContext.shiftDownOneOctave()
                    break
                case (.downward, .upward):
                    break
                case (.upward, .upward):
                    break
                case (.mixed, .downward):
                    tonalContext.shiftDownOneOctave()
                    break
                case (.downward, .downward):
                    tonalContext.shiftDownOneOctave()
                    break
                case (.mixed, .upward):
                    break
                default:
                    break
                }
            }
            if tonalContext.pitchDirection != newMode.pitchDirection {
                tonalContext.pitchDirection = newMode.pitchDirection
            }
            tonalContext.mode = newMode
            buzz()
        }
    }
    
}
