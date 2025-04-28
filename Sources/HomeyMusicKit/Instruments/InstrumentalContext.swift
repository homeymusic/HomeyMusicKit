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
    
    public var areModeAndTonicLinked: Bool = true {
        didSet {
            areModeAndTonicLinkedRaw = areModeAndTonicLinked
        }
    }
    
    public init() {
        self.instrumentChoice = InstrumentChoice(rawValue: instrumentChoiceRaw) ?? InstrumentChoice.default
        self.stringInstrumentChoice = InstrumentChoice(rawValue: stringInstrumentChoiceRaw) ?? InstrumentChoice.defaultStringInstrumentChoice
        self.areModeAndTonicLinked = areModeAndTonicLinked
    }
    
    var tonicOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    private var isTonicLocked = false
    
    public func setTonicLocations(tonicLocations: [CGPoint], tonicPicker: TonicPicker) {
        for location in tonicLocations {
            var tonicPitch: Pitch?
            for info in tonicOverlayCells.values where info.rect.contains(location) {
                if tonicPitch == nil {
                    tonicPitch = tonicPicker.pitch(for: MIDINoteNumber(info.identifier))
                }
            }
            
            if let t = tonicPitch {
                if !isTonicLocked {
                    
                    updateTonic(tonicPitch: t, tonicPicker: tonicPicker)
                    
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

    public func updateTonic(tonicPitch: Pitch, tonicPicker: TonicPicker) {
        buzz()
        tonicPicker.tonicPitch = tonicPitch

//        if tonicPicker.tonality.pitchDirection == .mixed {
//            if tonicPitch == tonicPicker.tonicPitch {
//                tonicPicker.tonalitytonalContext.shiftDownOneOctave()
//                buzz()
//                return
//            } else if tonicPitch.isOctave(relativeTo: tonalContext.tonicPitch) {
//                tonalContext.shiftUpOneOctave()
//                return
//            }
//        }
//        
//        if tonicPitch.isOctave(relativeTo: tonalContext.tonicPitch) {
//            if tonicPitch.midiNote.number > tonalContext.tonicPitch.midiNote.number {
//                tonalContext.pitchDirection = .downward
//            } else {
//                tonalContext.pitchDirection = .upward
//            }
//            tonalContext.tonicPitch = tonicPitch
//            return
//        } else {
//            if areModeAndTonicLinked {
//                let newMode: Mode = Mode(
//                    rawValue: modulo(
//                        tonalContext.mode.rawValue + Int(tonicPitch.distance(from: tonalContext.tonicPitch)), 12
//                    ))!
//                
//                tonalContext.tonicPitch = tonicPitch
//
//                if newMode != tonalContext.mode {
//                    let oldDirection = tonalContext.mode.pitchDirection
//                    let newDirection = newMode.pitchDirection
//                    switch (oldDirection, newDirection) {
//                    case (.upward, .downward):
//                        break
//                    case (.downward, .upward):
//                        break
//                    case (.upward, .upward):
//                        break
//                    case (.mixed, .downward):
//                        break
//                    case (.downward, .downward):
//                        break
//                    case (.mixed, .upward):
//                        break
//                    default:
//                        break
//                    }
//
//                    tonalContext.mode = newMode
//                    tonalContext.pitchDirection = newMode.pitchDirection
//                }
//            } else {
//                tonalContext.tonicPitch = tonicPitch
//            }
//            return
//        }
    }
    
    var modeOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    private var isModeLocked = false
    
    public func setModeLocations(modeLocations: [CGPoint], tonalContext: TonalContext) {
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
                    updateMode(m, tonalContext: tonalContext)
                    isModeLocked = true
                }
            }
        }
        
        if modeLocations.isEmpty {
            isModeLocked = false
        }
    }
    
    private func updateMode(_ newMode: Mode,
                            tonalContext: TonalContext) {
        
        if newMode != tonalContext.mode {
            if areModeAndTonicLinked {
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
