import SwiftUI
import SwiftData

public struct TonalityInstrumentView: View {
    private let tonalityInstrument: TonalityInstrument
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }

    let horizontalCellCount = 13.0

    public var body: some View {

//        if isModeOrTonicPickersShown {
            HStack(spacing: 5) {
//                if areModeAndTonicPickersShown {
                    modeAndTonicPickerToggleView(feetDirection: .right)
//                }
                VStack(spacing: 5) {
//                    if tonalityInstrument.showTonicPicker {
                        TonicInstrumentView(tonalityInstrument: tonalityInstrument)
                            .aspectRatio(horizontalCellCount, contentMode: .fit)
//                    }
//                    if tonalityInstrument.showModePicker {
                        ModeInstrumentView(tonalityInstrument: tonalityInstrument)
                            .aspectRatio(horizontalCellCount * aspectMultiplier, contentMode: .fit)
//                    }
                }
//                if areModeAndTonicPickersShown {
                    modeAndTonicPickerToggleView(feetDirection: .left)
//                }
            }
            .aspectRatio(ratio, contentMode: .fit)
//        } else {
//            EmptyView()
//        }
    }
    
    func modeAndTonicPickerToggleView(feetDirection: FeetDirection) -> some View {
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
            .aspectRatio(1/4, contentMode: .fit)
            .padding([.top, .bottom], 16)
        }
    }
    
    var ratio : CGFloat {
//        if areModeAndTonicPickersShown {
            return horizontalCellCount / (areBothModeNoteLabelsShown ? 2.0 : 1.5)
//        } else if tonalityInstrument.showModePicker {
//            return horizontalCellCount  * aspectMultiplier
//        } else {
//            return horizontalCellCount
//        }
    }
    
    var areModeAndTonicPickersShown: Bool {
        tonalityInstrument.showModePicker &&
        tonalityInstrument.showTonicPicker
    }
    
    var isModeOrTonicPickersShown: Bool {
        tonalityInstrument.showModePicker ||
        tonalityInstrument.showTonicPicker
    }
    
    var areBothModeNoteLabelsShown: Bool {
        tonalityInstrument.pitchLabelTypes.contains(.mode) &&
        tonalityInstrument.pitchLabelTypes.contains(.map)
    }
 
    var aspectMultiplier: CGFloat {
        if areBothModeNoteLabelsShown {
            return 1.0
        } else {
            return 2.0
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
