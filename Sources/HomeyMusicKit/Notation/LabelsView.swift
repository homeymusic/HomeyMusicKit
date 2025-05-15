import SwiftUI

public struct LabelsView: View {
    var pitch: Pitch
    let instrument: any Instrument
    var pitchCell: PitchCell
    var proxySize: CGSize
    
    public var body: some View {
        let padding = 2.0 + pitchCell.maxOutlineMultiplier
        return GeometryReader { proxy in
            VStack(spacing: 0.0) {
                if pitchCell.cellType == .span {
                    Labels(pitch: pitch, instrument: instrument, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                    Labels(pitch: pitch,  instrument: instrument, pitchCell: pitchCell, proxySize: proxySize, rotation: Angle.degrees(180))
                        .padding(padding)
                } else if pitchCell.cellType == .diamond {
                    Labels(pitch: pitch,  instrument: instrument, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                        .rotationEffect(Angle(degrees: -45))
                } else {
                    Labels(pitch: pitch,  instrument: instrument, pitchCell: pitchCell, proxySize: proxySize)
                        .padding(padding)
                }
            }
        }
    }
    
    struct Labels: View {
        let pitch: Pitch
        let instrument: any Instrument
        let pitchCell: PitchCell
        let proxySize: CGSize
        var rotation: Angle = .degrees(0)
        let withinDiamondPadding: CGFloat = 0.0
        let defaultPadding: CGFloat = 3.0
        let aroundDiamondPadding: CGFloat = 12.0
        
        var body: some View {
            
            VStack(spacing: 3) {
                if instrument is Piano {
                    pianoLayoutSpacer
                }
                if rotation == .degrees(180) || pitchCell.cellType == .swapNotation {
                    // TODO: reversed orders here
                    Group {
                        noteLabels(reverse: true)
                        symbolIcon
                        intervalLabels(reverse: true)
                    }
                    .padding(.top, pitchCell.cellType == .diamond ? withinDiamondPadding :
                                instrument is Diamanti ? aroundDiamondPadding : defaultPadding)
                    .padding(.bottom, defaultPadding)
                } else {
                    // TODO: default orders here
                    Group {
                        intervalLabels()
                        symbolIcon
                        noteLabels()
                    }
                    .padding(.top, defaultPadding)
                    .padding(.bottom, pitchCell.cellType == .diamond ? withinDiamondPadding :
                                instrument is Diamanti ? aroundDiamondPadding : defaultPadding)
                }
            }
            .padding(.horizontal, pitchCell.cellType == .diamond ? withinDiamondPadding : defaultPadding)
            .foregroundColor(pitchCell.textColor(
                majorMinor: pitchCell.pitch.majorMinor(for: instrument),
                isNatural: pitchCell.pitch.isNatural
            ))
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
                    array.append(AnyView(overlayText("\(pitch.pitchClass.letter(using: instrument.accidental))\(octave)")))
                }
                if showNoteLabel(for: .fixedDo) {
                    array.append(AnyView(overlayText("\(pitch.pitchClass.fixedDo(using: instrument.accidental))\(octave)")))
                }
                if showNoteLabel(for: .month) {
                    array.append(AnyView(overlayText("\(Calendar.current.shortMonthSymbols[(pitch.pitchClass.intValue + 3) % 12].capitalized)\(octave)")))
                }
                if showNoteLabel(for: .midi) {
                    array.append(AnyView(overlayText(String(pitch.midiNote.number))))
                }
                if instrument.showMIDIVelocity {
                    array.append(AnyView(overlayText(String(pitch.midiVelocity))))
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
                            Image(systemName: PitchLabelType.cochlea.icon)
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
                        pitch.consonanceDissonance(for: instrument).image
                            .resizable()
                            .rotationEffect(rotation)
                            .scaledToFit()
                            .font(Font.system(size: .leastNormalMagnitude,
                                              weight: pitch.consonanceDissonance(for: instrument).fontWeight))
                            .frame(maxWidth: pitch.consonanceDissonance(for: instrument).imageScale * proxySize.width / (2.0 * HomeyMusicKit.goldenRatio),
                                   maxHeight: pitch.consonanceDissonance(for: instrument).imageScale * proxySize.height / (2.0 * HomeyMusicKit.goldenRatio))
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
                        overlayText(String(pitch.interval(for: instrument)
                            .intervalClass.shorthand(for: instrument.pitchDirection)))
                    ))
                }
                if showIntervalLabel(for: .roman) {
                    arr.append(AnyView(
                        overlayText(
                            pitch.interval(for: instrument)
                                .roman(pitchDirection: instrument.pitchDirection),
                            font: .system(size: 14, weight: .regular, design: .serif)
                        )
                    ))
                }
                if showIntervalLabel(for: .degree) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument)
                            .degree(pitchDirection: instrument.pitchDirection)))
                    ))
                }
                if showIntervalLabel(for: .integer) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument).distance))
                    ))
                }
                if showIntervalLabel(for: .movableDo) {
                    arr.append(AnyView(
                        overlayText(pitch.interval(for: instrument).movableDo)
                    ))
                }
                if showIntervalLabel(for: .wavelengthRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument).wavelengthRatio))
                    ))
                }
                if showIntervalLabel(for: .wavenumberRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument).wavenumberRatio))
                    ))
                }
                if showIntervalLabel(for: .periodRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument).periodRatio))
                    ))
                }
                if showIntervalLabel(for: .frequencyRatio) {
                    arr.append(AnyView(
                        overlayText(String(pitch.interval(for: instrument).frequencyRatio))
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
#if os(macOS)
            Color.clear.overlay(
                Text(text)
                    .font(font ?? .title)
            )
#else
            Color.clear.overlay(
                Text(text)
                    .font(font ?? .body)
            )
#endif
        }
        
        func minDimension(_ size: CGSize) -> CGFloat {
            return min(size.width, size.height)
        }
        
        var isActivated: Bool {
            pitchCell.isActivated
        }
        
        var octave: String {
            showNoteLabel(for: .octave) ? String(pitch.octave) : ""
        }
        
        func showNoteLabel(for key: PitchLabelType) -> Bool {
            instrument.pitchLabelTypes.contains(key)
        }
        
        func showIntervalLabel(for key: IntervalLabelType) -> Bool {
            instrument.intervalLabelTypes.contains(key)
        }
        
    }
}
