import Darwin
import MIDIKitIO
import MIDIKitCore
import SwiftUI

public typealias MIDINoteNumber    = UInt7
public typealias MIDIVelocity      = UInt7
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
    public static let defaultMIDIVelocity: MIDIVelocity = 64
    
    /// Anchor points for converting host-time ticks → wall-clock Date
    private var hostTimeBase: UInt64 = 0
    private var dateBase:     Date   = .now
    
    public var identifiableMIDIEvents: [IdentifiableMIDIEvent] = []
    public var maxStoredEvents: Int = 1_000
    
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
        
        // ─── record our “zero” for ticks and Date() ───
        let ticks = mach_absolute_time()
        hostTimeBase = ticks * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
        dateBase     = Date()
        // ──────────────────────────────────────────────
        
        try? midiManager.addInputConnection(
            to: .allOutputs,
            tag: Self.inputConnectionName,
            receiver: .events { [weak self] events, timestampRaw, endpoint in
                guard let self = self else { return }
                Task { @MainActor in
                    for event in events {
                        Self.receiveMIDIEvent(
                            event,
                            from: self,
                            timestampRaw: timestampRaw,
                            sourceLabel: endpoint?.displayName
                        )
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
            switch instrument.midiOutChannelMode {
            case .all:
                for ch in MIDIChannel.allCases {
                    operation(instrument, ch)
                }
            case .none:
                break
            case .selected:
                operation(instrument, instrument.midiOutChannel)
            }
        }
    }
    
    @MainActor
    private static func receiveMIDIEvent(
        _ midiEvent: MIDIEvent,
        from midiConductor: MIDIConductor,
        timestampRaw: UInt64,
        sourceLabel: String?
    ) {
        // 1) raw ticks → nanoseconds
        let eventNano = timestampRaw
                      * UInt64(timebaseInfo.numer)
                      / UInt64(timebaseInfo.denom)
        // 2) delta since our base
        let deltaNano = eventNano &- midiConductor.hostTimeBase
        let deltaSec  = Double(deltaNano) / 1_000_000_000
        // 3) convert to a real Date
        let when = midiConductor.dateBase.addingTimeInterval(deltaSec)
        
        // 4) append with real Date
        midiConductor.identifiableMIDIEvents.append(
            IdentifiableMIDIEvent(
                midiEvent:   midiEvent,
                sourceLabel: sourceLabel.map { "From \($0)" },
                timestamp:   when
            )
        )
        
        // 5) FIFO trim
        let overflow = midiConductor.identifiableMIDIEvents.count
                     - midiConductor.maxStoredEvents
        if overflow > 0 {
            midiConductor.identifiableMIDIEvents.removeFirst(overflow)
        }
        
        // — rest of your existing sysEx7 / cc / noteOn / noteOff logic —
        switch midiEvent {
        case let .sysEx7(payload):
            guard
                payload.data.starts(with: whatUpDoe),
                let extractedUniqueID = payload.extractUniqueID(fromBaseLength: 3),
                extractedUniqueID != midiConductor.uniqueID
            else { return }
            
            guard let instrument = midiConductor.instrumentCache.selectedInstrument else {
                return
            }
            
            midiConductor.tonicMIDINoteNumber(
                instrument.tonality.tonicMIDINoteNumber,
                midiOutChannel: instrument.midiInChannel
            )
            midiConductor.pitchDirectionRaw(
                instrument.tonality.pitchDirectionRaw,
                midiOutChannel: instrument.midiInChannel
            )
            midiConductor.modeRaw(
                instrument.tonality.modeRaw,
                midiOutChannel: instrument.midiInChannel
            )
            
        case let .cc(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            switch payload.controller {
            case .generalPurpose1:
                let newTonic = payload.value.midi1Value
                for tonality in midiConductor.instrumentCache.tonalities {
                    tonality.tonicMIDINoteNumber = newTonic
                }
            case .generalPurpose2:
                let newDir = Int(payload.value.midi1Value)
                for tonality in midiConductor.instrumentCache.tonalities {
                    tonality.pitchDirectionRaw = newDir
                }
            case .generalPurpose3:
                let newMode = Int(payload.value.midi1Value)
                for tonality in midiConductor.instrumentCache.tonalities {
                    tonality.modeRaw = newMode
                }
            default: break
            }
            
        case let .noteOn(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            let midiChannel = MIDIChannel(rawValue: payload.channel) ?? .default
            midiConductor.dispatch(to: midiChannel) { instrument in
                guard let mi = instrument as? MusicalInstrument else { return }
                mi.activateMIDINoteNumber(
                    midiNoteNumber: payload.note.number,
                    midiVelocity:   payload.velocity.midi1Value
                )
            }
            
        case let .noteOff(payload):
            midiConductor.suppressOutgoingMIDI = true
            defer { midiConductor.suppressOutgoingMIDI = false }
            let midiChannel = MIDIChannel(rawValue: payload.channel) ?? .default
            midiConductor.dispatch(to: midiChannel) { instrument in
                guard let mi = instrument as? MusicalInstrument else { return }
                mi.deactivateMIDINoteNumber(midiNoteNumber: payload.note.number)
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
                velocity: .midi1(pitch.midiVelocity),
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
    
    public func tonicMIDINoteNumber(
        _ midiNoteNumber: MIDINoteNumber,
        midiOutChannel: MIDIChannel
    ) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose1,
                value: .midi1(midiNoteNumber),
                channel: midiOutChannel.rawValue
            )
        )
    }
    
    public func pitchDirectionRaw(
        _ pitchDirectionRaw: PitchDirection.RawValue,
        midiOutChannel: MIDIChannel
    ) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose2,
                value: .midi1(UInt7(pitchDirectionRaw)),
                channel: midiOutChannel.rawValue
            )
        )
    }
    
    public func modeRaw(
        _ modeRaw: Mode.RawValue,
        midiOutChannel: MIDIChannel
    ) {
        guard !suppressOutgoingMIDI else { return }
        try? outputConnection?.send(
            event: .cc(
                .generalPurpose3,
                value: .midi1(UInt7(modeRaw)),
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
        return try .sysEx7(
            manufacturer: manufacturer,
            data: data,
            group: group
        )
    }
    
    func extractUniqueID(
        fromBaseLength baseLength: Int = 3,
        idLength: Int = 4
    ) -> [UInt8]? {
        guard data.count >= baseLength + idLength else { return nil }
        return Array(data[baseLength ..< baseLength + idLength])
    }
}

// ticks→nanoseconds conversion factors
private let timebaseInfo: mach_timebase_info_data_t = {
    var info = mach_timebase_info_data_t()
    mach_timebase_info(&info)
    return info
}()

