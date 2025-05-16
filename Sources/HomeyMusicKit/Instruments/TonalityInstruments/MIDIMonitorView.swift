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

        Table(identifiableMIDIEvents) {
            TableColumn("Time") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.timestamp, format: midiTimeFormat)
            }
            TableColumn("Source") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.sourceLabel ?? "")
            }
            TableColumn("Message") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.messageLabel)
            }
            TableColumn("Channel") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.channelLabel)
            }
            TableColumn("Data") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.dataLabel)
            }
            TableColumn("Raw Hex") { (identifiableMIDIEvent: IdentifiableMIDIEvent) in
                Text(identifiableMIDIEvent.rawHexLabel)
            }            
        }
    }
}

