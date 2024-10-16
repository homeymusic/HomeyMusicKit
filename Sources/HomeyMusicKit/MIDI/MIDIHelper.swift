//
//  MIDIState.swift
//  HomeyMusicKit
//
//  Created by Brian McAuliff Mulloy on 9/28/24.
//

public enum MIDIState {
    case on, off
}

public struct MIDIHelper {
    // Safe MIDI checker function
    public static func isValidMIDI(midi: Int) -> Bool {
        return midi >= 0 && midi <= 127
    }
}
