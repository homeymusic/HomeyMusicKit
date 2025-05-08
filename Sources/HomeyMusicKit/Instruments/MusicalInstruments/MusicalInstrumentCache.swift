import SwiftUI

@Observable
public final class MusicalInstrumentCache {
    
    public func selectMusicalInstrument(_ musicalInstrument: (any MusicalInstrument)?) {
        cleanup()
        selectedMusicalInstrument = musicalInstrument
    }
    
    public func set(_ musicalInstruments: [any MusicalInstrument]) {
        items = musicalInstruments.map(WeakInstrument.init)
    }

    public func musicalInstruments(midiOutChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { musicalInstrument in
            switch musicalInstrument.midiOutChannelMode {
            case .all:
                return true
            case .none:
                return false
            case .selected:
                return musicalInstrument.midiOutChannel == midiOutChannel
            }
        }
    }
    
    public func musicalInstruments(midiInChannel: MIDIChannel) -> [any MusicalInstrument] {
        all.filter { musicalInstrument in
            switch musicalInstrument.midiInChannelMode {
            case .all:
                return true
            case .none:
                return false
            case .selected:
                return musicalInstrument.midiInChannel == midiInChannel
            }
        }
    }
    
    public var selectedMusicalInstrument: (any MusicalInstrument)?
    
    // Wrap each instrument weakly so we don't keep them alive unintentionally
    private final class WeakInstrument {
        weak var value: (any MusicalInstrument)?
        init(_ musicalInstrument: any MusicalInstrument) { self.value = musicalInstrument }
    }
    
    // The backing storage of weak instrument references
    private var items: [WeakInstrument] = []
    
    public init() {}
    
    // delete all below here:
    
    /// Remove *all* cached instruments
    public func clear() {
        items.removeAll()
    }
    
    public var all: [any MusicalInstrument] {
        cleanup()
        return items.compactMap { $0.value }
    }
    
    /// Purge any wrappers whose instrument was deallocated
    private func cleanup() {
        items.removeAll { $0.value == nil }
    }
}
