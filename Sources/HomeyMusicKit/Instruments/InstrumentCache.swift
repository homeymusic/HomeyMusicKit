import SwiftUI

@Observable
public final class InstrumentCache {
    
    public func selectInstrument(_ instrument: (any Instrument)?) {
        cleanup()
        selectedInstrument = instrument
    }
    
    public func set(_ instruments: [any Instrument]) {
        items = instruments.map(WeakInstrument.init)
    }

    public func instruments(midiOutChannel: MIDIChannel) -> [any Instrument] {
        all.filter { instrument in
            switch instrument.midiOutChannelMode {
            case .all:
                return true
            case .none:
                return false
            case .selected:
                return instrument.midiOutChannel == midiOutChannel
            }
        }
    }
    
    public func instruments(midiInChannel: MIDIChannel) -> [any Instrument] {
        all.filter { instrument in
            switch instrument.midiInChannelMode {
            case .all:
                return true
            case .none:
                return false
            case .selected:
                return instrument.midiInChannel == midiInChannel
            }
        }
    }
    
    public var selectedInstrument: (any Instrument)?
    
    // Wrap each instrument weakly so we don't keep them alive unintentionally
    private final class WeakInstrument {
        weak var value: (any Instrument)?
        init(_ instrument: any Instrument) { self.value = instrument }
    }
    
    // The backing storage of weak instrument references
    private var items: [WeakInstrument] = []
    
    public init() {}
    
    // delete all below here:
    
    /// Remove *all* cached instruments
    public func clear() {
        items.removeAll()
    }
    
    public var all: [any Instrument] {
        cleanup()
        return items.compactMap { $0.value }
    }
    
    /// Purge any wrappers whose instrument was deallocated
    private func cleanup() {
        items.removeAll { $0.value == nil }
    }
}
