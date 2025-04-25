import Foundation
import SwiftUI

public protocol Instrument: ObservableObject {
    var instrumentChoice: InstrumentChoice { get }
    
    /// store the hit-boxes so you can look them up later
    var pitchOverlayCells: [InstrumentCoordinate: OverlayCell] { get set }

    /// handle a new batch of touches
    func setPitchLocations(
        pitchLocations: [CGPoint],
        tonalContext: TonalContext
    )
}

public extension Instrument {
    func setPitchLocations(
        pitchLocations: [CGPoint],
        tonalContext: TonalContext
    ) {
        var touchedPitches = Set<Pitch>()
        
        for location in pitchLocations {
            var picked: Pitch?
            var highestZ = -1
            
            // pick the topmost key under this touch
            for cell in pitchOverlayCells.values where cell.contains(location) {
                if picked == nil || cell.zIndex > highestZ {
                    picked     = tonalContext.pitch(
                                    for: MIDINoteNumber(cell.identifier)
                                )
                    highestZ   = cell.zIndex
                }
            }
            
            if let pitch = picked {
                touchedPitches.insert(pitch)
                
                // simple on/off activation
                if !pitch.isActivated {
                    pitch.activate()
                }
            }
        }
        
        // release any pitches no longer touched
        for pitch in tonalContext.activatedPitches {
            if !touchedPitches.contains(pitch) {
                pitch.deactivate()
            }
        }
    }
}


// TODO: all this must come back:

//private var latchingTouchedPitches = Set<Pitch>()
//
//public func setPitchLocations(
//    pitchLocations: [CGPoint],
//    tonalContext: TonalContext,
//    instrument: any Instrument
//) {
//    var touchedPitches = Set<Pitch>()
//    
//    // Process the touch locations and determine which keys are touched
//    for location in pitchLocations {
//        var pitch: Pitch?
//        var highestZindex = -1
//        
//        // Find the pitch at this location with the highest Z-index
//        for pitchRectangle in pitchOverlayCells.values where pitchRectangle.contains(location) {
//            if pitch == nil || pitchRectangle.zIndex > highestZindex {
//                pitch = tonalContext.pitch(for: MIDINoteNumber(pitchRectangle.identifier))
//                highestZindex = pitchRectangle.zIndex
//            }
//        }
//        
//        if let p = pitch {
//            touchedPitches.insert(p)
//            
//            if latching {
//                if !latchingTouchedPitches.contains(p) {
//                    latchingTouchedPitches.insert(p)
//                    
//                    if instrumentChoice == .tonnetz {
//                        if p.pitchClass.isActivated(in: tonalContext.activatedPitches) {
//                            p.pitchClass.deactivate(in: tonalContext.activatedPitches)
//                        } else {
//                            p.activate()
//                        }
//                    } else {
//                        // Toggle pitch activation
//                        if p.isActivated {
//                            p.deactivate()
//                        } else {
//                            p.activate()
//                        }
//                    }
//                }
//            } else {
//                if !p.isActivated {
//                    p.activate()
//                }
//            }
//        }
//    }
//    
//    if !latching {
//        for pitch in tonalContext.activatedPitches {
//            if !touchedPitches.contains(pitch) {
//                pitch.deactivate()
//            }
//        }
//    }
//    
//    if pitchLocations.isEmpty {
//        latchingTouchedPitches.removeAll()  // Clear for the next interaction
//    }
//}
//
//
