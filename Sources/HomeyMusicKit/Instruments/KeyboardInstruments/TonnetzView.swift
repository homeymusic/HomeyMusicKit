import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    
    var body: some View {
        ZStack {
            
            drawLattice()
            
            drawTriads()
            
            GeometryReader { geometry in
                let rowIndices = tonnetz.rowIndices
                let colIndices = tonnetz.colIndices
                let cellWidth  = geometry.size.width / CGFloat(colIndices.count)
                
                VStack(spacing: 0) {
                    ForEach(rowIndices, id: \.self) { row in
                        let integerOffset = Int(floor(Double(row) / 2.0))
                        let fractionalOffset = Double(row) / 2.0 - Double(integerOffset)
                        HStack(spacing: 0) {
                            ForEach(colIndices.indices, id: \.self) { index in
                                let col = colIndices[index]
                                let isLastCol = (index == colIndices.count - 1)
                                let noteNumber: Int = tonnetz.noteNumber(
                                    row: Int(row),
                                    col: Int(col),
                                    offset: integerOffset,
                                    tonalContext: tonalContext
                                )
                                let pitchClassMIDI: Int = tonnetz.pitchClassMIDI(
                                    noteNumber: noteNumber,
                                    tonalContext: tonalContext
                                )
                                Group {
                                    if Pitch.isValid(pitchClassMIDI) && !(isLastCol && fractionalOffset != 0.0) {
                                        let pitch = tonalContext.pitch(for: MIDINoteNumber(pitchClassMIDI))
                                        PitchView(
                                            pitch: pitch,
                                            row: row,
                                            col: col,
                                            offset: (fractionalOffset == 0.0) ? false : true,
                                            containerType: .tonnetz
                                        )
                                    } else {
                                        Color.clear
                                    }
                                }
                            }                    }
                        .offset(x: fractionalOffset * cellWidth)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
        }
    }
    
    @ViewBuilder
    private func drawTriads() -> some View {
        ForEach(Array(instrumentalContext.pitchRectInfos), id: \.key) { (coord, rootInfo) in
            
            // 1) Build the "major" triad coords
            let fourSemitonesCoord = InstrumentCoordinate(row: coord.row + 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1 : coord.col)
            let sevenSemitonesCoord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col + 1)
            
            // If they exist:
            if let fourSemitones = instrumentalContext.pitchRectInfos[fourSemitonesCoord],
               let sevenSemitones = instrumentalContext.pitchRectInfos[sevenSemitonesCoord] {
                
                // Pass the 3 info objects to TriadView
                TriadView(
                    chord: [rootInfo, fourSemitones, sevenSemitones],
                    chordShape: .positive
                )
            }
            
            // 2) Build the "minor" triad coords
            let threeSemitonesCoord = InstrumentCoordinate(row: coord.row - 1,
                                               col: rootInfo.layoutOffset ? coord.col : coord.col - 1)
            let fiveSemitonesCoord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col - 1)
            
            if let threeSemitonesInfo = instrumentalContext.pitchRectInfos[threeSemitonesCoord],
               let fiveSemitonesInfo = instrumentalContext.pitchRectInfos[fiveSemitonesCoord] {
                
                TriadView(
                    chord: [rootInfo, threeSemitonesInfo, fiveSemitonesInfo],
                    chordShape: .negative
                )
            }
        }
    }
    
    struct TriadView: View {
        let chord: [PitchRectInfo]
        let chordShape: ChordShape
        // If you need to pass more info (e.g. major or minor triad?), you could store it.
        
        @Environment(TonalContext.self) var tonalContext
        
        /// The shape we’ll draw if all 3 pitches are active.
        /// Otherwise, we don’t show it (or fill with .clear).
        var body: some View {
            // Make sure we have exactly 3 infos
            guard chord.count == 3 else { return AnyView(EmptyView()) }
            
            // Convert each info’s midiNoteNumber to a Pitch
            let pitches = chord.map { tonalContext.pitch(for: $0.midiNoteNumber) }
            
            // Check if all are activated
            let allActive = pitches.allSatisfy {
                $0.pitchClass.isActivated(in: tonalContext.activatedPitches)
            }
            
            // Build the triangle
            let points = chord.map { $0.center }
            
            if allActive {
                // If you want a fill
                return AnyView(
                    BorderedTriangleView(points: points, chordShape: chordShape)
                )
            } else {
                // If not active, skip or show .clear
                return AnyView(EmptyView())
            }
        }
    }
    
    struct BorderedTriangleView: View {
        let points: [CGPoint]
        let chordShape: ChordShape

        var body: some View {
            ZStack {
                // Draw the filled triangle.
                TriangleShape(points: points)
                    .fill(chordShape.majorMinor.color.opacity(1 / HomeyMusicKit.goldenRatio))
                LineShape(points: [points[0], points[1]])
                    .stroke(chordShape.majorMinor.color, lineWidth: 10)
                LineShape(points: [points[1], points[2]])
                    .stroke(chordShape.majorMinor.color, lineWidth: 10)
                LineShape(points: [points[2], points[0]])
                    .stroke(chordShape.majorMinor.color, lineWidth: 10)
            }
            .clipShape(TriangleShape(points: points))
        }
    }
    
    struct TriangleShape: Shape {
        let points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            guard points.count == 3 else { return path }
            
            path.move(to: points[0])
            path.addLine(to: points[1])
            path.addLine(to: points[2])
            path.closeSubpath()
            return path
        }
    }
    
    @ViewBuilder
    private func drawLattice() -> some View {
        ForEach(Array(instrumentalContext.pitchRectInfos), id: \.key) { (coord, rootInfo) in
            
            let sevenSemitonesCoord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col + 1)
            if let sevenSemitones = instrumentalContext.pitchRectInfos[sevenSemitonesCoord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, sevenSemitones],
                    fillColor: MajorMinor.neutralColor
                )
            }
            
            let fourSemitonesCoord = InstrumentCoordinate(row: coord.row + 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1: coord.col)
            if let fourSemitones = instrumentalContext.pitchRectInfos[fourSemitonesCoord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, fourSemitones],
                    fillColor: MajorMinor.neutralColor
                )
            }
            
            let threeSemitonesCoord = InstrumentCoordinate(row: coord.row - 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1: coord.col)
            if let threeSemitones = instrumentalContext.pitchRectInfos[threeSemitonesCoord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, threeSemitones],
                    fillColor: MajorMinor.neutralColor
                )
            }
        }
    }
    
    struct LatticeView: View {
        let chord: [PitchRectInfo]
        let fillColor: Color
        // If you need to pass more info (e.g. major or minor triad?), you could store it.
        
        @Environment(TonalContext.self) var tonalContext
        
        /// The shape we’ll draw if all 3 pitches are active.
        /// Otherwise, we don’t show it (or fill with .clear).
        var body: some View {
            guard chord.count == 2 else { return AnyView(EmptyView()) }
            let points = chord.map { $0.center }
            let pitches = chord.map { tonalContext.pitch(for: $0.midiNoteNumber) }
            let allActive = pitches.allSatisfy {
                $0.pitchClass.isActivated(in: tonalContext.activatedPitches)
            }

            return AnyView(
                LineShape(points: points)
                    .stroke(fillColor.opacity(allActive ? 1.0 : 1 / HomeyMusicKit.goldenRatio), lineWidth: allActive ? 10 : 1)
            )
        }
    }
    
    struct LineShape: Shape {
        let points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            guard points.count == 2 else { return path }
            
            path.move(to: points[0])
            path.addLine(to: points[1])
            path.closeSubpath()
            return path
        }
    }
    
}
