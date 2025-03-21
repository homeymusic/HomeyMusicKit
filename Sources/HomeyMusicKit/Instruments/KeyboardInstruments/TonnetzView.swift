import SwiftUI
import MIDIKitCore

struct TonnetzView: View {
    @ObservedObject var tonnetz: Tonnetz
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    
    var body: some View {
        ZStack {
            
            drawTriads()
            
            drawLattice()
            
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
                                        PitchContainerView(
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
        .clipShape(Rectangle())
    }
    
    @ViewBuilder
    private func drawTriads() -> some View {
        ForEach(Array(instrumentalContext.pitchRectInfos), id: \.key) { (coord, rootInfo) in
            
            // 1) Build the "major" triad coords
            let M3Coord = InstrumentCoordinate(row: coord.row + 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1 : coord.col)
            let P5Coord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col + 1)
            
            // If they exist:
            if let M3 = instrumentalContext.pitchRectInfos[M3Coord],
               let P5 = instrumentalContext.pitchRectInfos[P5Coord] {
                
                // Pass the 3 info objects to TriadView
                TriadView(
                    chord: [rootInfo, M3, P5],
                    fillColor: MajorMinor.majorColor
                )
            }
            
            // 2) Build the "minor" triad coords
            let m3Coord = InstrumentCoordinate(row: coord.row - 1,
                                               col: rootInfo.layoutOffset ? coord.col : coord.col - 1)
            let P4Coord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col - 1)
            
            if let m3Info = instrumentalContext.pitchRectInfos[m3Coord],
               let P4Info = instrumentalContext.pitchRectInfos[P4Coord] {
                
                TriadView(
                    chord: [rootInfo, m3Info, P4Info],
                    fillColor: MajorMinor.minorColor
                )
            }
        }
    }
    
    struct TriadView: View {
        let chord: [PitchRectInfo]
        let fillColor: Color
        // If you need to pass more info (e.g. major or minor triad?), you could store it.
        
        @EnvironmentObject var tonalContext: TonalContext
        
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
                    TriangleShape(points: points)
                        .fill(fillColor.opacity(1/HomeyMusicKit.goldenRatio))
                        .overlay(
                            TriangleShape(points: points)
                                .stroke(Color(HomeyMusicKit.backgroundColor), lineWidth: 1)
                        )
                )
            } else {
                // If not active, skip or show .clear
                return AnyView(EmptyView())
            }
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
            
            let P5Coord = InstrumentCoordinate(row: coord.row,
                                               col: coord.col + 1)
            if let P5 = instrumentalContext.pitchRectInfos[P5Coord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, P5],
                    fillColor: MajorMinor.neutralColor
                )
            }
            
            let M3Coord = InstrumentCoordinate(row: coord.row + 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1: coord.col)
            if let M3 = instrumentalContext.pitchRectInfos[M3Coord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, M3],
                    fillColor: MajorMinor.majorColor
                )
            }
            
            let m3Coord = InstrumentCoordinate(row: coord.row - 1,
                                               col: rootInfo.layoutOffset ? coord.col + 1: coord.col)
            if let m3 = instrumentalContext.pitchRectInfos[m3Coord] {
                // Pass the 3 info objects to TriadView
                LatticeView(
                    chord: [rootInfo, m3],
                    fillColor: MajorMinor.minorColor
                )
            }
            
        }
    }
    
    struct LatticeView: View {
        let chord: [PitchRectInfo]
        let fillColor: Color
        // If you need to pass more info (e.g. major or minor triad?), you could store it.
        
        @EnvironmentObject var tonalContext: TonalContext
        
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
                    .stroke(fillColor.opacity(allActive ? 1.0 : 1 / HomeyMusicKit.goldenRatio), lineWidth: allActive ? 5 : 1)
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
