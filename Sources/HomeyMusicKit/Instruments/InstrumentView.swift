import SwiftUI

public struct InstrumentView: Identifiable, View {
    private let instrument: any Instrument
    public let id = UUID()

    @State public var midiNoteNumberOverlayCells: [InstrumentCoordinate: OverlayCell] = [:]
    @State private var latchedMIDINoteNumbers: Set<MIDINoteNumber> = []

    @Environment(SynthConductor.self) private var synthConductor
    @Environment(MIDIConductor.self)  private var midiConductor
    
    public init(_ instrument: any Instrument) {
        self.instrument                = instrument
    }

    public var body: some View {
        
        instrument.midiConductor  = midiConductor
        instrument.synthConductor = synthConductor
        
        return ZStack {
            switch instrument {
            case let tonnetz as Tonnetz:
                TonnetzView(
                    tonnetz: tonnetz,
                    midiNoteNumberOverlayCells: midiNoteNumberOverlayCells
                )
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
                setMIDINoteNumberLocations(
                    touches,
                    instrument: instrument
                )
            }
        }
        .onChange(of: instrument.latching) {
            if !instrument.latching {
                latchedMIDINoteNumbers.removeAll()
                instrument.deactivateAllMIDINoteNumbers()
            }
        }
        .onPreferenceChange(OverlayCellKey.self) { newCells in
            Task { @MainActor in
                midiNoteNumberOverlayCells = newCells
            }
        }
        .coordinateSpace(name: HomeyMusicKit.instrumentSpace)
    }

    private func setMIDINoteNumberLocations(
        _ touchPoints: [CGPoint],
        instrument: any Instrument
    ) {
        var touchedMIDINoteNumbers = Set<MIDINoteNumber>()

        for touchPoint in touchPoints {
            var bestMatchingMIDINoteNumber: MIDINoteNumber?
            var highestCellZIndex = -1

            for overlayCell in midiNoteNumberOverlayCells.values where overlayCell.contains(touchPoint) {
                if overlayCell.zIndex > highestCellZIndex {
                    highestCellZIndex = overlayCell.zIndex
                    bestMatchingMIDINoteNumber = MIDINoteNumber(overlayCell.identifier)
                }
            }

            guard let midiNoteNumber = bestMatchingMIDINoteNumber else { continue }
            touchedMIDINoteNumbers.insert(midiNoteNumber)

            if instrument.latching {
                if !latchedMIDINoteNumbers.contains(midiNoteNumber) {
                    latchedMIDINoteNumbers.insert(midiNoteNumber)

                    if instrument.instrumentChoice == .tonnetz {
                        let pitch = instrument.tonality.pitch(for: midiNoteNumber)
                        if pitch.pitchClass.isActivated(in: instrument.tonality.activatedPitches) {
                            pitch.pitchClass.deactivate(in: instrument.tonality.activatedPitches)
                        } else {
                            instrument.activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
                        }
                    } else {
                        instrument.toggleMIDINoteNumber(midiNoteNumber: midiNoteNumber)
                    }
                }
            } else {
                if !instrument.tonality.activatedPitches.contains(where: { $0.midiNote.number == midiNoteNumber }) {
                    instrument.activateMIDINoteNumber(midiNoteNumber: midiNoteNumber)
                }
            }
        }

        if !instrument.latching {
            for activePitch in instrument.tonality.activatedPitches {
                let activeMIDINoteNumber = activePitch.midiNote.number
                if !touchedMIDINoteNumbers.contains(activeMIDINoteNumber) {
                    instrument.deactivateMIDINoteNumber(midiNoteNumber: activeMIDINoteNumber)
                }
            }
        }

        if touchPoints.isEmpty {
            latchedMIDINoteNumbers.removeAll()
        }
    }
}
