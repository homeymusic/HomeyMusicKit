import Foundation
import CoreGraphics
import SwiftData

public protocol Instrument: AnyObject, Observable {
    var instrumentChoice: InstrumentChoice { get }
    
    /// “Latch” mode on/off
    var latching: Bool { get set }

    /// store the hit-boxes so you can look them up later
    var pitchOverlayCells: [InstrumentCoordinate: OverlayCell] { get set }

    
    /// Tracks which pitches have already fired in a latching tap
    var latchingTouchedPitches: Set<Pitch> { get set }

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
            if latching {
                if !latchingTouchedPitches.contains(p) {
                    latchingTouchedPitches.insert(p)

                    if instrumentChoice == .tonnetz {
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
        if !latching {
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
