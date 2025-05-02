import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDINoteNumber    = UInt7
public typealias MIDIChannelNumber = UInt4

@Observable
public final class MIDIConductor: @unchecked Sendable {
    public let clientName:   String
    public let model:        String
    public let manufacturer: String

    private let instrumentCache: InstrumentCache
    private var suppressOutgoingMIDI = false
    private let midiManager: ObservableMIDIManager
    private let uniqueID: [UInt8] = (0..<4).map { _ in UInt8.random(in: 0...127) }

    public static let whatUpDoe: [UInt8] = [0x03, 0x01, 0x03]

    public init(
        clientName: String,
        model: String,
        manufacturer: String,
        instrumentCache: InstrumentCache
    ) {
        self.clientName      = clientName
        self.model           = model
        self.manufacturer    = manufacturer
        self.instrumentCache = instrumentCache
        self.midiManager     = ObservableMIDIManager(
            clientName:   clientName,
            model:        model,
            manufacturer: manufacturer,
            notificationHandler: { _ in }
        )
    }

    public func setup() {
        try? midiManager.start()
        try? midiManager.addInputConnection(
            to: .allOutputs,
            tag: Self.inputConnectionName,
            receiver: .events { [weak self] events, _, _ in
                guard let self = self else { return }
                Task { @MainActor in
                    for event in events {
                        Self.receiveMIDIEvent(event, from: self)
                    }
                }
            }
        )
        try? midiManager.addOutputConnection(
            to: .allInputs,
            tag: Self.outputConnectionName
        )
        statusRequest()
    }

    public func dispatch(
        to midiChannel: MIDIChannel,
        _ operation: (any Instrument) -> Void
    ) {
        let instrumentsForChannel = instrumentCache.instruments(midiInChannel: midiChannel)
        for instrument in instrumentsForChannel {
            operation(instrument)
        }
    }

    public func dispatch(
        from midiChannel: MIDIChannel,
        _ operation: (any Instrument, MIDIChannel) -> Void
    ) {
        let instrumentsForChannel = instrumentCache.instruments(midiOutChannel: midiChannel)
        for instrument in instrumentsForChannel {
            if instrument.allMIDIOutChannels {
                // “Broadcast” to 1…16
                for ch in MIDIChannel.allCases {
                    operation(instrument, ch)
                }
            } else {
                // Single‐channel case
                operation(instrument, midiChannel)
            }
        }
    }
    
    @MainActor
    private static func receiveMIDIEvent(
        _ event: MIDIEvent,
        from midiConductor: MIDIConductor
    ) {
        switch event {
        case let .sysEx7(payload):
            guard
                payload.data.starts(with: whatUpDoe),
                let extractedUniqueID = payload.extractUniqueID(fromBaseLength: 3),
                extractedUniqueID != midiConductor.uniqueID
            else {
                return
            }

            guard let instrument = midiConductor.instrumentCache.selectedInstrument
            else {
                // nothing selected → do nothing (or you could fall back to first instrument on the slide)
                return
            }

            midiConductor.tonicPitch(instrument.tonicPitch, midiOutChannel: instrument.midiInChannel)
            midiConductor.pitchDirection(instrument.pitchDirection, midiOutChannel:  instrument.midiInChannel)
            midiConductor.mode(instrument.mode, midiOutChannel:  instrument.midiInChannel)
            
        case let .cc(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            let midiChannel = MIDIChannel(rawValue: payload.channel) ?? .default
            switch payload.controller {
            case .generalPurpose1:
                midiConductor.dispatch(to: midiChannel) { instrument in
                    instrument.tonality.tonicPitch = instrument.pitch(for: payload.value.midi1Value)
                }
            case .generalPurpose2:
                midiConductor.dispatch(to: midiChannel) { instrument in
                    if let direction = PitchDirection(rawValue: Int(payload.value.midi1Value)) {
                        instrument.pitchDirection = direction
                    }
                }
            case .generalPurpose3:
                midiConductor.dispatch(to: midiChannel) { instrument in
                    if let mode = Mode(rawValue: Int(payload.value.midi1Value)) {
                        instrument.mode = mode
                    }
                }
            default:
                break
            }
        case let .noteOn(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            let midiChannel = MIDIChannel(rawValue: payload.channel) ?? .default
            midiConductor.dispatch(to: midiChannel) { instrument in
                instrument.activateMIDINoteNumber(midiNoteNumber: payload.note.number)
            }
        case let .noteOff(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            let midiChannel = MIDIChannel(rawValue: payload.channel) ?? .default
            midiConductor.dispatch(to: midiChannel) { instrument in
                instrument.deactivateMIDINoteNumber(midiNoteNumber: payload.note.number)
            }
        default:
            break
        }
    }

    public var outputConnection: MIDIOutputConnection? {
        midiManager.managedOutputConnections[Self.outputConnectionName]
    }

    private func statusRequest() {
        if let event = try? MIDIEvent.SysEx7.statusRequestEvent(withUniqueID: uniqueID) {
            try? outputConnection?.send(event: event)
        }
    }

    public func noteOn(pitch: Pitch, midiOutChannel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .noteOn(
                pitch.midiNote.number,
                velocity: .midi1(64),
                channel: midiOutChannel.rawValue
            )
        )
    }

    public func noteOff(pitch: Pitch, midiOutChannel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .noteOff(
                pitch.midiNote.number,
                velocity: .midi1(0),
                channel: midiOutChannel.rawValue
            )
        )
    }

    public func tonicPitch(_ pitch: Pitch, midiOutChannel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose1,
                value: .midi1(pitch.midiNote.number),
                channel: midiOutChannel.rawValue
            )
        )
    }

    public func pitchDirection(_ direction: PitchDirection, midiOutChannel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose2,
                value: .midi1(UInt7(direction.rawValue)),
                channel: midiOutChannel.rawValue
            )
        )
    }

    public func mode(_ mode: Mode, midiOutChannel: MIDIChannel) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose3,
                value: .midi1(UInt7(mode.rawValue)),
                channel: midiOutChannel.rawValue
            )
        )
    }

    public func allNotesOffAllChannels() {
        guard let connection = outputConnection else { return }
        for channelIndex in 0..<16 {
            for noteIndex in 0..<128 {
                try? connection.send(
                    event: .noteOff(
                        MIDINoteNumber(noteIndex),
                        velocity: .midi1(0),
                        channel: MIDIChannelNumber(channelIndex)
                    )
                )
            }
        }
    }

    public static let inputConnectionName  = "HomeyMusicKit Input Connection"
    public static let outputConnectionName = "HomeyMusicKit Output Connection"
}

extension MIDIEvent.SysEx7 {
    static func statusRequestEvent(
        withUniqueID uniqueID: [UInt8],
        manufacturer: MIDIEvent.SysExManufacturer = .educational(),
        baseData: [UInt8] = MIDIConductor.whatUpDoe,
        group: MIDIChannelNumber = 0x0
    ) throws -> MIDIEvent {
        var data = baseData
        data.append(contentsOf: uniqueID)
        return try .sysEx7(manufacturer: manufacturer, data: data, group: group)
    }

    func extractUniqueID(fromBaseLength baseLength: Int = 3, idLength: Int = 4) -> [UInt8]? {
        guard data.count >= baseLength + idLength else { return nil }
        return Array(data[baseLength ..< baseLength + idLength])
    }
}
