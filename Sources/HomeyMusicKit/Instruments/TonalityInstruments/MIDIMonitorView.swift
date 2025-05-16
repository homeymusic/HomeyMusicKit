import SwiftUI
import MIDIKitCore

// Simple Identifiable wrapper for each event's debugDescription
private struct MIDIEventRow: Identifiable {
    let id = UUID()
    let text: String
}

public struct MIDIMonitorView: View {
    @Bindable public var tonalityInstrument: TonalityInstrument

    public init(_ tonalityInstrument: TonalityInstrument) {
        self.tonalityInstrument = tonalityInstrument
    }

    public var body: some View {
        let events = tonalityInstrument.midiConductor?.midiEvents ?? []
        let rows = events.map { MIDIEventRow(text: $0.debugDescription) }

        Table(rows) {
            TableColumn("Event", value: \.text)
        }
    }
}
