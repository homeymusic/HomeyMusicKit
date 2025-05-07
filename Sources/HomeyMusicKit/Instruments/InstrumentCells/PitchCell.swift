import SwiftUI
import SwiftData
import MIDIKitCore

public struct PitchCell: View, CellProtocol {
    let pitch: Pitch
    let instrument: any Instrument
    let row: Int
    let col: Int
    let offset: Bool
    let zIndex: Int
    let cellType: CellType
    let namedCoordinateSpace: String

    @Environment(\.modelContext) var modelContext

    public init(
        pitch: Pitch,
        instrument: any Instrument,
        row: Int,
        col: Int,
        offset: Bool = false,
        zIndex: Int = 0,
        cellType: CellType = .basic,
        namedCoordinateSpace: String = HomeyMusicKit.instrumentSpace
    ) {
        self.pitch = pitch
        self.instrument = instrument
        self.row = row
        self.col = col
        self.offset = offset
        self.zIndex = zIndex
        self.cellType = cellType
        self.namedCoordinateSpace = namedCoordinateSpace
    }

    // Layout / Appearance Variables
    
    var backgroundBorderSize: CGFloat { 3.0 }
    
    var borderWidthApparentSize: CGFloat {
        if cellType == .diamond || isSmall {
            return 2.0 * backgroundBorderSize
        } else {
            return backgroundBorderSize
        }
    }
    
    var borderHeightApparentSize: CGFloat {
        cellType == .diamond ? 2.0 * backgroundBorderSize : backgroundBorderSize
    }
    
    var outlineWidth: CGFloat {
        borderWidthApparentSize * outlineMultiplier
    }
    
    var outlineHeight: CGFloat {
        borderHeightApparentSize * outlineMultiplier
    }
    
    var alignment: Alignment {
        instrument is Piano
            ? .top
            : .center
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named(namedCoordinateSpace))
            Color.clear
                .preference(
                    key: OverlayCellKey.self,
                    value: [
                        InstrumentCoordinate(row: row, col: col): OverlayCell(
                            rect: rect,
                            identifier: Int(pitch.midiNote.number),
                            zIndex: zIndex,
                            layoutOffset: offset,
                            cellType: cellType
                        )
                    ]
                )
                .overlay(
                    ZStack(alignment: alignment) {
                        // Base shape
                        CellShape(
                            fillColor: .black,
                            pitchCell: self,
                            proxySize: proxy.size
                        )
                        .overlay(alignment: alignment) {
                            // Compute safe (non-negative) sizes
                            let safeW = max(proxy.size.width  - borderWidthApparentSize,  0)
                            let safeH = max(proxy.size.height - borderHeightApparentSize, 0)
                            
                            if isOutlined {
                                let safeW2 = max(proxy.size.width  - outlineWidth,  0)
                                let safeH2 = max(proxy.size.height - outlineHeight, 0)
                                
                                // Outline layer
                                CellShape(
                                    fillColor: outlineColor(
                                        majorMinor: pitch.majorMinor(for: instrument)
                                    ),
                                    pitchCell: self,
                                    proxySize: proxy.size
                                )
                                .frame(width: safeW, height: safeH)
                                .overlay(alignment: alignment) {
                                    // Inner fill
                                    CellShape(
                                        fillColor: cellColor(
                                            majorMinor: pitch.majorMinor(for: instrument),
                                            isNatural: pitch.isNatural
                                        ),
                                        pitchCell: self,
                                        proxySize: proxy.size
                                    )
                                    .frame(width: safeW2, height: safeH2)
                                }
                            } else {
                                // Non-outlined fill
                                CellShape(
                                    fillColor: cellColor(
                                        majorMinor: pitch.majorMinor(for: instrument),
                                        isNatural: pitch.isNatural
                                    ),
                                    pitchCell: self,
                                    proxySize: proxy.size
                                )
                                .frame(width: safeW, height: safeH)
                                .padding(.leading, leadingOffset)
                                .padding(.trailing, trailingOffset)
                            }
                        }
                    }
                    .overlay(
                        LabelsView(
                            pitch: pitch,
                            instrument: instrument,
                            pitchCell: self,
                            proxySize: proxy.size
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                )
        }
    }
    
    // Custom overrides for padding
    func topPadding(_ size: CGSize) -> CGFloat {
        instrument is Piano
            ? relativeCornerRadius(in: size)
            : 0.0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        instrument is Piano
            ? -relativeCornerRadius(in: size)
            : 0.0
    }
    
    var isActivated: Bool {
        if instrument is TonalityInstrument {
            return pitch.pitchClass.isActivated(in: instrument.tonality.allActivatedPitches)
        } else if instrument is Tonnetz {
            return pitch.pitchClass.isActivated(in: instrument.activatedPitches)
        } else {
            return pitch.isActivated
        }
    }
    
    var maxOutlineMultiplier: CGFloat {
        isSmall ? 2.0 : 3.0
    }
    
    var outlineMultiplier: CGFloat {
        if pitch.consonanceDissonance(for: instrument) == .tonic {
            return maxOutlineMultiplier
        } else if cellType == .diamond {
            return maxOutlineMultiplier / 2.0
        } else {
            return maxOutlineMultiplier * 2.0 / 3.0
        }
    }
    
    var isOutlined: Bool {
        guard instrument.showOutlines else {
            return false
        }

        let interval = pitch.interval(for: instrument)

        if instrument.showTonicOctaveOutlines &&
           (interval.isTonic || interval.isOctave) {
            return true
        }

        if instrument.showModeOutlines {
            let cls = interval.intervalClass
            return instrument.mode.intervalClasses.contains([cls])
        }

        return false
    }
    
    var isSmall: Bool {
        instrument is Piano &&
        !pitch.isNatural
    }
}
