//
//  MIDIState.swift
//  HomeyMusicKit
//
//  Created by Brian McAuliff Mulloy on 9/28/24.
//

import MIDIKitCore

public enum MIDIState {
    case on, off
}

public struct MIDIHelper {
    // Safe MIDI checker function
    public static func isValidMIDI(note: Int) -> Bool {
        return note >= 0 && note <= 127
    }
}

public typealias MIDIChannel = UInt4
