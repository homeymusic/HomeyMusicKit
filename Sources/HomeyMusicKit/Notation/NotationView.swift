import SwiftUI

public struct NotationView: View {
    var pitch: Pitch
    var pitchView: PitchView
    var proxySize: CGSize
    
    @EnvironmentObject var tonalContext: TonalContext
    @EnvironmentObject var instrumentalContext: InstrumentalContext
    @EnvironmentObject var notationalContext: NotationalContext

    public var body: some View {
        let padding = 2.0 + pitchView.maxOutlineMultiplier
        return GeometryReader { proxy in
            VStack(spacing: 0.0) {
                if pitchView.containerType == .span {
                    Labels(pitch: pitch, pitchView: pitchView, proxySize: proxySize)
                        .padding(padding)
                    Labels(pitch: pitch, pitchView: pitchView, proxySize: proxySize, rotation: Angle.degrees(180))
                        .padding(padding)
                } else {
                    Labels(pitch: pitch, pitchView: pitchView, proxySize: proxySize)
                        .padding(padding)
                }
            }
        }
    }
    
    struct Labels: View {
        let pitch: Pitch
        let pitchView: PitchView
        let proxySize: CGSize
        var rotation: Angle = .degrees(0)
        
        @EnvironmentObject var tonalContext: TonalContext
        @EnvironmentObject var instrumentalContext: InstrumentalContext
        @EnvironmentObject var notationalContext: NotationalContext
        @EnvironmentObject var notationalTonicContext: NotationalTonicContext

        var thisNotationalContext: NotationalContext {
            pitchView.containerType == .tonicPicker ? notationalTonicContext : notationalContext
        }
        
        var body: some View {
            
            VStack(spacing: 1) {
                Spacer()
                if instrumentalContext.instrumentChoice == .piano && pitchView.containerType != .tonicPicker {
                    pianoLayoutSpacer
                }
                noteLabels
                symbolIcon
                intervalLabels
                Spacer()
            }
            .padding(0.0)
            .foregroundColor(textColor)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        }
        
        var pianoLayoutSpacer: some View {
            VStack(spacing: 0) {
                Color.clear
            }
            .frame(height: proxySize.height / HomeyMusicKit.goldenRatio)
        }
        
        var noteLabels: some View {
            AnyView(
                Group {
                    if showNoteLabel(for: .letter) {
                        overlayText("\(pitch.pitchClass.letter(using: tonalContext.accidental))\(octave)")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .fixedDo) {
                        overlayText("\(pitch.pitchClass.fixedDo(using: tonalContext.accidental))\(octave)")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .month) {
                        overlayText("\(Calendar.current.shortMonthSymbols[(pitch.pitchClass.intValue + 3) % 12].capitalized)\(octave)")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .midi) {
                        overlayText(String(pitch.midiNote.number))
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .wavelength) {
                        overlayText("\("λ") \(pitch.wavelength.formatted(.number.notation(.compactName).precision(.significantDigits(3))))m")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .wavenumber) {
                        overlayText("\("k") \(pitch.wavenumber.formatted(.number.notation(.compactName).precision(.significantDigits(3))))m⁻¹")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .period) {
                        overlayText("\("T") \((pitch.fundamentalPeriod * 1000.0).formatted(.number.notation(.compactName).precision(.significantDigits(4))))ms")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .frequency) {
                        overlayText("\("f") \(pitch.fundamentalFrequency.formatted(.number.notation(.compactName).precision(.significantDigits(3))))Hz")
                    } else {
                        EmptyView()
                    }
                    if showNoteLabel(for: .cochlea) {
                        overlayText("\(pitch.cochlea.formatted(.number.notation(.compactName).precision(.significantDigits(3))))%")
                    } else {
                        EmptyView()
                    }
                }
            )
        }
        
        var symbolIcon: some View {
            if showIntervalLabel(for: .symbol) {
                return AnyView(
                    Color.clear.overlay(
                        pitch.consonanceDissonance(for: tonalContext).image
                            .resizable()
                            .rotationEffect(rotation)
                            .scaledToFit()
                            .font(Font.system(size: .leastNormalMagnitude,
                                              weight: pitch.consonanceDissonance(for: tonalContext).fontWeight))
                            .frame(maxWidth: pitch.consonanceDissonance(for: tonalContext).imageScale * proxySize.width / (2.0 * HomeyMusicKit.goldenRatio),
                                   maxHeight: pitch.consonanceDissonance(for: tonalContext).imageScale * proxySize.height / (2.0 * HomeyMusicKit.goldenRatio))
                            .animation(.easeInOut(duration: 0.3),
                                       value: pitch.interval(for: tonalContext).isTonic)
                    )
                )
            }
            return AnyView(EmptyView())
        }
        
        var intervalLabels: some View {
            return Group {
                if showIntervalLabel(for: .interval) {
                    overlayText(String(pitch.interval(for: tonalContext).intervalClass.shorthand(for: tonalContext.pitchDirection)))
                }
                if showIntervalLabel(for: .roman) {
                    overlayText(
                        pitch.interval(for: tonalContext)
                             .roman(pitchDirection: tonalContext.pitchDirection),
                        font: .system(size: 14, weight: .regular, design: .serif)
                    )
                }
                if showIntervalLabel(for: .degree) {
                    overlayText(String(pitch.interval(for: tonalContext).degree(pitchDirection: tonalContext.pitchDirection)))
                }
                if showIntervalLabel(for: .integer) {
                    overlayText(String(pitch.interval(for: tonalContext).distance))
                }
                if showIntervalLabel(for: .movableDo) {
                    overlayText(pitch.interval(for: tonalContext).movableDo)
                }
                if showIntervalLabel(for: .wavelengthRatio) {
                    overlayText(String(pitch.interval(for: tonalContext).wavelengthRatio))
                }
                if showIntervalLabel(for: .wavenumberRatio) {
                    overlayText(String(pitch.interval(for: tonalContext).wavenumberRatio))
                }
                if showIntervalLabel(for: .periodRatio) {
                    overlayText(String(pitch.interval(for: tonalContext).periodRatio))
                }
                if showIntervalLabel(for: .frequencyRatio) {
                    overlayText(String(pitch.interval(for: tonalContext).frequencyRatio))
                }
            }
        }
        
        func overlayText(_ text: String, font: Font? = nil) -> some View {
            Color.clear.overlay(
                Text(text)
                    .font(font ?? .body)  // default to body if no font was passed
            )
        }
        
        func minDimension(_ size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
        var isActivated: Bool {
            pitchView.isActivated
        }
        
        var textColor: Color {
            let activeColor: Color
            let inactiveColor: Color
            switch notationalContext.colorPalette[instrumentalContext.instrumentChoice]! {
            case .subtle:
                activeColor = Color(HomeyMusicKit.primaryColor)
                inactiveColor = Color(pitch.interval(for: tonalContext).majorMinor.color)
            case .loud:
                activeColor = Color(pitch.interval(for: tonalContext).majorMinor.color)
                inactiveColor = Color(HomeyMusicKit.primaryColor)
            case .ebonyIvory:
                return pitch.isNatural ? .black : .white
            }
            return isActivated ? activeColor : inactiveColor
        }
        
        var octave: String {
            thisNotationalContext.noteLabels[instrumentalContext.instrumentChoice]![.octave]! ? String(pitch.octave) : ""
        }
        
        func showNoteLabel(for key: NoteLabelChoice) -> Bool {
            if pitchView.containerType == .tonicPicker {
                return notationalTonicContext.noteLabels[.tonicPicker]![key]!
            } else {
                return notationalContext.noteLabels[instrumentalContext.instrumentChoice]![key]!
            }
        }
        
        func showIntervalLabel(for key: IntervalLabelChoice) -> Bool {
            if pitchView.containerType == .tonicPicker {
                return notationalTonicContext.intervalLabels[.tonicPicker]![key]!
            } else {
                return notationalContext.intervalLabels[instrumentalContext.instrumentChoice]![key]!
            }
        }

    }
}
