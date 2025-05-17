import SwiftUI
import MIDIKitCore

public struct MIDIMonitorView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument
    
    private let midiTimeFormat = Date.FormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .second(.twoDigits)
        .secondFraction(.fractional(3))
    
    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }
    
    public var body: some View {
        let identifiableMIDIEvents = tonalityInstrument
            .midiConductor?
            .identifiableMIDIEvents ?? []
        
        VStack {
            ScrollViewReader { proxy in
                Table(identifiableMIDIEvents) {
                    TableColumn("Time") { event in
                        Text(event.timestamp, format: midiTimeFormat)
                    }
                    TableColumn("Source") { event in
                        Text(event.sourceLabel ?? "")
                    }
                    TableColumn("Message") { event in
                        Text(event.messageLabel)
                    }
                    TableColumn("Channel") { event in
                        Text(event.channelLabel)
                    }
                    TableColumn("Data") { event in
                        Text(event.dataLabel)
                    }
                    TableColumn("Raw Hex") { event in
                        Text(event.rawHexLabel)
                    }
                }
                .onChange(of: identifiableMIDIEvents.count, initial: true) { _, _ in
                    if let last = identifiableMIDIEvents.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    tonalityInstrument.midiConductor?.identifiableMIDIEvents.removeAll()
                }) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
