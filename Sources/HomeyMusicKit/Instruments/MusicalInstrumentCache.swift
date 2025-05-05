import SwiftUI

@Observable
public final class MusicalInstrumentCache {
    
    public var selectedMusicalInstrument: (any MusicalInstrument)?
    
    public func selectMusicalInstrument(_ musicalInstrument: (any MusicalInstrument)?) {
        cleanup()
        selectedMusicalInstrument = musicalInstrument
    }
    
    // Wrap each instrument weakly so we don't keep them alive unintentionally
    private final class WeakInstrument {
        weak var value: (any MusicalInstrument)?
        init(_ musicalInstrument: any MusicalInstrument) { self.value = musicalInstrument }
    }
    
    // The backing storage of weak instrument references
    private var items: [WeakInstrument] = []
    
    public init() {}
    
    /// Remove *all* cached instruments
    public func clear() {
        items.removeAll()
    }
    
    /// Replace the cache with exactly this set of instruments
    public func set(_ musicalInstruments: [any MusicalInstrument]) {
        items = musicalInstruments.map(WeakInstrument.init)
    }
    
    /// Add one instrument to the cache
    public func add(_ musicalInstrument: any MusicalInstrument) {
        cleanup()
        items.append(WeakInstrument(musicalInstrument))
    }
    
    /// Remove one instrument (or any deallocated ones) from the cache
    public func remove(_ musicalInstrument: any MusicalInstrument) {
        items.removeAll { wrap in
            wrap.value == nil || wrap.value === musicalInstrument
        }
    }
    
    /// All *currently alive* instruments in the cache
    public var all: [any MusicalInstrument] {
        cleanup()
        return items.compactMap { $0.value }
    }
    
    public func musicalInstruments(midiInChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { musicalInstrument in
            musicalInstrument.allMIDIInChannels || musicalInstrument.midiInChannel == midiInChannel
        }
    }
    
    public func musicalInstruments(midiOutChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { musicalInstrument in
            musicalInstrument.allMIDIOutChannels || musicalInstrument.midiOutChannel == midiOutChannel
        }
    }
    
    /// Purge any wrappers whose instrument was deallocated
    private func cleanup() {
        items.removeAll { $0.value == nil }
    }
}
