import MIDIKit
import AVFoundation
import AudioKit
import DunneAudioKit

@Observable
public class SynthConductor {
    let engine = AudioEngine()
    var synthesizer = Synth()
    
    public init() {
        configureAudioSession()
        addObservers()
        engine.output = PeakLimiter(synthesizer, attackTime: 0.001, decayTime: 0.001, preGain: 0)
        configureInstrument()
        start()
    }
    
    // Configure audio session only on iOS.
    func configureAudioSession() {
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setPreferredIOBufferDuration(0.001) // e.g. 5 ms
            try audioSession.setCategory(.playback, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
        #elseif os(macOS)
        // macOS doesn't use AVAudioSession.
        // You can add macOS-specific audio configuration here if needed.
        #endif
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            print("Error starting the engine: \(error)")
        }
    }
    
    public func reloadAudio() {
        self.configureAudioSession()
        self.start()
    }

    public func noteOn(pitch: Pitch) {
        synthesizer.play(noteNumber: UInt8(pitch.midiNote.number), velocity: UInt8(pitch.midiVelocity), channel: 0)
    }
    
    public func noteOff(pitch: Pitch) {
        synthesizer.stop(noteNumber: UInt8(pitch.midiNote.number), channel: 0)
    }
    
    public func allNotesOff() {
        for noteNumber in UInt8(0)...UInt8(127) {
            synthesizer.stop(noteNumber: noteNumber, channel: 0)
        }
    }
    
    private func configureInstrument() {
        synthesizer.masterVolume = 0.8
        synthesizer.pitchBend = 0
        synthesizer.attackDuration = 0.02
        synthesizer.filterAttackDuration = 0.1
        synthesizer.decayDuration = 1.5
        synthesizer.filterDecayDuration = 0.4
        synthesizer.sustainLevel = 0.1
        synthesizer.filterSustainLevel = 0.05
        synthesizer.releaseDuration = 0.8
        synthesizer.filterReleaseDuration = 0.3
        synthesizer.filterCutoff = 4.0
        synthesizer.filterResonance = -1.0
        synthesizer.filterStrength = 0.2
        synthesizer.vibratoDepth = 0.03
    }
    
    // Register notifications only on iOS.
    func addObservers() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification, object: nil)
        #endif
    }
    
    @objc func handleRouteChange(notification: Notification) {
        #if os(iOS)
        guard let userInfo = notification.userInfo,
              let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        
        switch reason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue,
             AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
            reloadAudio()
        default:
            break
        }
        #endif
    }
    
    @objc func handleInterruption(notification: Notification) {
        #if os(iOS)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            engine.stop()
        } else if type == .ended {
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                reloadAudio()
            }
        }
        #endif
    }
}
