import SwiftUI
import MIDIKitCore

@Observable
public final class TonalityCache {
    /// All cached tonalities
    private(set) public var items: [Tonality] = []
    /// The currently selected tonality, if any
    public var selectedTonality: Tonality?

    public init() {}
    
    public func set(_ tonalities: [Tonality]) {
        items = tonalities
    }

    /// Replace the cache contents
    public func update(with tonalities: [Tonality]) {
        items = tonalities
    }

    /// Mark one as “selected”
    public func select(_ tonality: Tonality?) {
        selectedTonality = tonality
    }

    /// All tonalities in the cache
    public var all: [Tonality] {
        items
    }

    public func tonalities(forMidiOut midiChannel: MIDIChannel) -> [Tonality] {
        items.filter { tonality in
            tonality.musicalInstruments.contains { musicalInstrument in
                switch musicalInstrument.midiOutChannelMode {
                case .all:
                    return true
                case .none:
                    return false
                case .selected:
                    return musicalInstrument.midiOutChannel == midiChannel
                }
            }
        }
    }

    public func tonalities(forMidiIn midiChannel: MIDIChannel) -> [Tonality] {
        items.filter { tonality in
            tonality.musicalInstruments.contains { musicalInstrument in
                switch musicalInstrument.midiInChannelMode {
                case .all:
                    return true
                case .none:
                    return false
                case .selected:
                    return musicalInstrument.midiInChannel == midiChannel
                }
            }
        }
    }
    
    public func clear() {
        items.removeAll()
    }
}
