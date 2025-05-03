import SwiftUI

@Observable
public final class InstrumentCache {
    
    public var selectedInstrument: (any MusicalInstrument)?
    
    public func selectInstrument(_ instrument: (any MusicalInstrument)?) {
        cleanup()
        selectedInstrument = instrument
    }
    
    // Wrap each instrument weakly so we don't keep them alive unintentionally
    private final class WeakInstrument {
        weak var value: (any MusicalInstrument)?
        init(_ instrument: any MusicalInstrument) { self.value = instrument }
    }
    
    // The backing storage of weak instrument references
    private var items: [WeakInstrument] = []
    
    public init() {}
    
    /// Remove *all* cached instruments
    public func clear() {
        items.removeAll()
    }
    
    /// Replace the cache with exactly this set of instruments
    public func set(_ instruments: [any MusicalInstrument]) {
        items = instruments.map(WeakInstrument.init)
    }
    
    /// Add one instrument to the cache
    public func add(_ instrument: any MusicalInstrument) {
        cleanup()
        items.append(WeakInstrument(instrument))
    }
    
    /// Remove one instrument (or any deallocated ones) from the cache
    public func remove(_ instrument: any MusicalInstrument) {
        items.removeAll { wrap in
            wrap.value == nil || wrap.value === instrument
        }
    }
    
    /// All *currently alive* instruments in the cache
    public var all: [any MusicalInstrument] {
        cleanup()
        return items.compactMap { $0.value }
    }
    
    public func instruments(midiInChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { instrument in
            instrument.allMIDIInChannels || instrument.midiInChannel == midiInChannel
        }
    }
    
    public func instruments(midiOutChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { instrument in
            instrument.allMIDIOutChannels || instrument.midiOutChannel == midiOutChannel
        }
    }
    
    /// Purge any wrappers whose instrument was deallocated
    private func cleanup() {
        items.removeAll { $0.value == nil }
    }
}
