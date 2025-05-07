import SwiftUI
import SwiftData

public struct TonalityInstrumentView: View {
    private let tonalityInstrument: TonalityInstrument
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }
    
    public var body: some View {
        if tonalityInstrument.isModeOrTonicPickersShown {
            HStack(spacing: 5) {
                if tonalityInstrument.areModeAndTonicPickersShown {
                    modeAndTonicLinkerToggleView(feetDirection: .right)
                        .aspectRatio(tonalityInstrument.areBothModeLabelsShown ? 0.25 : (1.0 / 3.0), contentMode: .fit)
                        .padding(.vertical, 6)
                }
                VStack(spacing: 5) {
                    if tonalityInstrument.showTonicPicker {
                        TonicPickerInstrumentView(tonalityInstrument: tonalityInstrument)
                            .aspectRatio(TonalityInstrument.horizontalCellCount, contentMode: .fit)
                    }
                    if tonalityInstrument.showModePicker {
                        ModePickerInstrumentView(tonalityInstrument: tonalityInstrument)
                            .aspectRatio(TonalityInstrument.horizontalCellCount * tonalityInstrument.modePickerAspectMultiplier, contentMode: .fit)
                    }
                }
                if tonalityInstrument.areModeAndTonicPickersShown {
                    modeAndTonicLinkerToggleView(feetDirection: .left)
                        .aspectRatio(tonalityInstrument.areBothModeLabelsShown ? 0.25 : (1.0 / 3.0), contentMode: .fit)
                        .padding(.vertical, 6)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    func modeAndTonicLinkerToggleView(feetDirection: FeetDirection) -> some View {
        return Button(action: {
            withAnimation {
                tonalityInstrument.areModeAndTonicLinked.toggle()
                buzz()
            }
        }) {
            ZStack {
                Group {
                    let strokeStyle = StrokeStyle(
                        lineWidth: 1,
                        dash: tonalityInstrument.areModeAndTonicLinked ? [] : [3, 1]
                    )
                    switch feetDirection {
                    case .left:
                        VerticalLineWithFeet(direction: .right)
                            .stroke(style: strokeStyle)
                    case .right:
                        VerticalLineWithFeet(direction: .left)
                            .stroke(style: strokeStyle)
                    }
                }
                if  tonalityInstrument.areModeAndTonicLinked {
                    Image(systemName: "personalhotspot.circle.fill")
                        .font(.title)
                        .background(
                            Rectangle()
                                .fill(.black)
                        )
                } else {
                    Image(systemName: "personalhotspot.circle.fill")
                        .font(.title)
                        .background(
                            Rectangle()
                                .fill(.black)
                        )
                        .foregroundColor(.clear)
                        .overlay(
                            HomeyMusicKit.modeAndTonicUnlinkedImage
                                .foregroundColor(.white)
                                .font(.callout)
                                .padding([.top, .bottom], 3)
                        )
                }
            }
//            .aspectRatio(1/4, contentMode: .fit)
//            .padding([.top, .bottom], 0)
        }
    }
        
    enum FeetDirection {
        case left
        case right
    }
    
    struct VerticalLineWithFeet: Shape {
        let direction: FeetDirection
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let centerX = rect.midX
            let topY = rect.minY
            let bottomY = rect.maxY
            let edgeX = direction == .left ? rect.maxX : rect.minX
            
            // Vertical line
            path.move(to: CGPoint(x: centerX, y: topY))
            path.addLine(to: CGPoint(x: centerX, y: bottomY))
            
            // Top foot
            path.move(to: CGPoint(x: centerX, y: topY))
            path.addLine(to: CGPoint(x: edgeX, y: topY))
            
            // Bottom foot
            path.move(to: CGPoint(x: centerX, y: bottomY))
            path.addLine(to: CGPoint(x: edgeX, y: bottomY))
            
            return path
        }
    }
}
