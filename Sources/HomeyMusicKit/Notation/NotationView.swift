import SwiftUI

public struct NotationView: View {
    var pitch: Pitch
    var pitchCell: PitchCell
    var proxySize: CGSize
    
    @Environment(TonalContext.self) var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext
    @Environment(NotationalContext.self) var notationalContext
    
    public var body: some View {
        let padding = 2.0 + pitchCell.maxOutlineMultiplier
        return GeometryReader { proxy in
            VStack(spacing: 0.0) {
                if pitchCell.cellType == .span {
                    Labels(pitch: pitch, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                    Labels(pitch: pitch, pitchCell: pitchCell, proxySize: proxySize, rotation: Angle.degrees(180))
                        .padding(padding)
                } else if pitchCell.cellType == .diamond {
                    Labels(pitch: pitch, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                        .rotationEffect(Angle(degrees: -45))
                } else {
                    Labels(pitch: pitch, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                }
            }
        }
    }
    
    struct Labels: View {
        let pitch: Pitch
        let pitchCell: PitchCell
        let proxySize: CGSize
        var rotation: Angle = .degrees(0)
        
        @Environment(TonalContext.self) var tonalContext
        @Environment(InstrumentalContext.self) var instrumentalContext
        @Environment(NotationalContext.self) var notationalContext
        @Environment(NotationalTonicContext.self) var notationalTonicContext
        
        var thisNotationalContext: NotationalContext {
            pitchCell.cellType == .tonicPicker ? notationalTonicContext : notationalContext
        }
        
        var body: some View {
            
            VStack(spacing: 1) {
                if instrumentalContext.instrumentChoice == .piano && pitchCell.cellType != .tonicPicker {
                    pianoLayoutSpacer
                }
                if rotation == .degrees(180) || pitchCell.cellType == .swapNotation {
                    // TODO: reversed orders here
                    intervalLabels(reverse: true)
                    symbolIcon
                    noteLabels(reverse: true)
                } else {
                    // TODO: default orders here
                    noteLabels()
                    symbolIcon
                    intervalLabels()
                }
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
        
        /// New function that builds and returns note labels in normal or reversed order.
        func noteLabels(reverse: Bool = false) -> some View {
            // Build the labels into an array.
            let views: [AnyView] = {
                var array = [AnyView]()
                if showNoteLabel(for: .letter) {
                    array.append(AnyView(overlayText("\(pitch.pitchClass.letter(using: tonalContext.accidental))\(octave)")))
                }
                if showNoteLabel(for: .fixedDo) {
                    array.append(AnyView(overlayText("\(pitch.pitchClass.fixedDo(using: tonalContext.accidental))\(octave)")))
                }
                if showNoteLabel(for: .month) {
                    array.append(AnyView(overlayText("\(Calendar.current.shortMonthSymbols[(pitch.pitchClass.intValue + 3) % 12].capitalized)\(octave)")))
                }
                if showNoteLabel(for: .midi) {
                    array.append(AnyView(overlayText(String(pitch.midiNote.number))))
                }
                if showNoteLabel(for: .wavelength) {
                    array.append(AnyView(overlayText("λ: \(pitch.wavelength.formatted(.number.notation(.compactName).precision(.significantDigits(3))))m")))
                }
                if showNoteLabel(for: .wavenumber) {
                    array.append(AnyView(overlayText("k: \(pitch.wavenumber.formatted(.number.notation(.compactName).precision(.significantDigits(3))))m⁻¹")))
                }
                if showNoteLabel(for: .period) {
                    array.append(AnyView(overlayText("T: \((pitch.fundamentalPeriod * 1000.0).formatted(.number.notation(.compactName).precision(.significantDigits(4))))ms")))
                }
                if showNoteLabel(for: .frequency) {
                    array.append(AnyView(overlayText("f: \(pitch.fundamentalFrequency.formatted(.number.notation(.compactName).precision(.significantDigits(3))))Hz")))
                }
                if showNoteLabel(for: .cochlea) {
                    array.append(AnyView(
                        HStack(spacing: 0) {
                            Image(systemName: NoteLabelChoice.cochlea.icon)
                                .scaleEffect(1.0 / HomeyMusicKit.goldenRatio)
                            overlayText("\(pitch.cochlea.formatted(.number.notation(.compactName).precision(.significantDigits(3))))%")
                        }
                    ))
                }
                return array
            }()
            
            // Reverse the array if requested.
            let finalViews = reverse ? Array(views.reversed()) : views
            
            // Render the views in a vertical stack.
            return Group {
                ForEach(Array(finalViews.enumerated()), id: \.offset) { _, view in
                    view
                }
            }
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
                    )
                )
            }
            return AnyView(EmptyView())
        }
        
        func intervalLabels(reverse: Bool = false) -> some View {
            // Build an array of AnyView for each label
            let views: [AnyView] = {
                var arr = [AnyView]()
                if showIntervalLabel(for: .interval) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext)
                            .intervalClass.shorthand(for: tonalContext.pitchDirection)))
                    ))
                }
                if showIntervalLabel(for: .roman) {
                    arr.append(AnyView(
                        overlayText(
                            pitch.interval(for: tonalContext)
                                .roman(pitchDirection: tonalContext.pitchDirection),
                            font: .system(size: 14, weight: .regular, design: .serif)
                        )
                    ))
                }
                if showIntervalLabel(for: .degree) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext)
                            .degree(pitchDirection: tonalContext.pitchDirection)))
                    ))
                }
                if showIntervalLabel(for: .integer) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext).distance))
                    ))
                }
                if showIntervalLabel(for: .movableDo) {
                    arr.append(AnyView(
                        overlayText(pitch.interval(for: tonalContext).movableDo)
                    ))
                }
                if showIntervalLabel(for: .wavelengthRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext).wavelengthRatio))
                    ))
                }
                if showIntervalLabel(for: .wavenumberRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext).wavenumberRatio))
                    ))
                }
                if showIntervalLabel(for: .periodRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext).periodRatio))
                    ))
                }
                if showIntervalLabel(for: .frequencyRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: tonalContext).frequencyRatio))
                    ))
                }
                return arr
            }()
            
            let finalViews = reverse ? Array(views.reversed()) : views
            
            return Group {
                ForEach(Array(finalViews.enumerated()), id: \.offset) { _, view in
                    view
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
            pitchCell.isActivated
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
            if pitchCell.cellType == .tonicPicker {
                return notationalTonicContext.noteLabels[.tonicPicker]![key]!
            } else {
                return notationalContext.noteLabels[instrumentalContext.instrumentChoice]![key]!
            }
        }
        
        func showIntervalLabel(for key: IntervalLabelChoice) -> Bool {
            if pitchCell.cellType == .tonicPicker {
                return notationalTonicContext.intervalLabels[.tonicPicker]![key]!
            } else {
                return notationalContext.intervalLabels[instrumentalContext.instrumentChoice]![key]!
            }
        }
        
    }
}
