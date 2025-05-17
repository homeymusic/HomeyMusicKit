import SwiftUI
import MIDIKitCore

public struct MIDIMonitorView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument
    
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
                        Text(event.timestampLabel)
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(ideal: 30)
                    
                    TableColumn("Source") { event in
                        Text(event.sourceLabel ?? "")
                            .font(.system(.body, design: .monospaced))
                    }
                    TableColumn("Message") { event in
                        Text(event.messageLabel)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    TableColumn("Channel") { event in
                        Text(event.channelLabel)
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(ideal: 30)
                    
                    TableColumn("Data") { event in
                        Text(event.dataLabel)
                            .font(.system(.body, design: .monospaced))
                    }
                    TableColumn("Raw Hex") { event in
                        Text(event.rawHexLabel)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .onChange(of: identifiableMIDIEvents.count, initial: true) { _, _ in
                    if let last = identifiableMIDIEvents.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottomLeading)
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
