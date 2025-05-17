import MIDIKit
import AVFoundation
import AudioKit
import DunneAudioKit

@Observable
public class SynthConductor {
    let engine = AudioEngine()
    var synthesizer = Synth()

    public init() {
        configureAudioSession()   // only does anything on iOS
        addObservers()            // only registers on iOS
        engine.output = PeakLimiter(
            synthesizer,
            attackTime: 0.001,
            decayTime: 0.001,
            preGain: 0
        )
        configureInstrument()
        start()
    }

    /// iOS: set up AVAudioSession to mixWithOthers
    /// macOS: no-op
    func configureAudioSession() {
        #if os(iOS)
        let session = Settings.session
        do {
            try session.setPreferredIOBufferDuration(0.001)
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
            print("→ session:", session.category.rawValue, session.categoryOptions)
        } catch {
            print("Error setting up audio session:", error)
        }
        #elseif os(macOS)
        // nothing needed on macOS
        #endif
    }

    /// Start the engine and re-assert mixWithOthers on iOS
    /// macOS just starts the engine
    public func start() {
        do {
            try engine.start()
            #if os(iOS)
            let session = Settings.session
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
            print("→ session after start:", session.category.rawValue, session.categoryOptions)
            #endif
        } catch {
            print("Error starting engine or session:", error)
        }
    }

    /// iOS: stop, deactivate, re-configure & restart
    /// macOS: just restart the engine
    public func reloadAudio() {
        engine.stop()
        #if os(iOS)
        let session = Settings.session
        try? session.setActive(false)
        configureAudioSession()
        #endif
        start()
    }

    // MARK: – MIDI note handling

    public func noteOn(pitch: Pitch) {
        synthesizer.play(
            noteNumber: UInt8(pitch.midiNote.number),
            velocity: UInt8(pitch.midiVelocity),
            channel: 0
        )
    }

    public func noteOff(pitch: Pitch) {
        synthesizer.stop(
            noteNumber: UInt8(pitch.midiNote.number),
            channel: 0
        )
    }

    public func allNotesOff() {
        for noteNumber in UInt8(0)...UInt8(127) {
            synthesizer.stop(
                noteNumber: noteNumber,
                channel: 0
            )
        }
    }

    // MARK: – Synth parameters

    private func configureInstrument() {
        synthesizer.masterVolume          = 0.8
        synthesizer.pitchBend             = 0
        synthesizer.attackDuration        = 0.02
        synthesizer.filterAttackDuration  = 0.1
        synthesizer.decayDuration         = 1.5
        synthesizer.filterDecayDuration   = 0.4
        synthesizer.sustainLevel          = 0.1
        synthesizer.filterSustainLevel    = 0.05
        synthesizer.releaseDuration       = 0.8
        synthesizer.filterReleaseDuration = 0.3
        synthesizer.filterCutoff          = 4.0
        synthesizer.filterResonance       = -1.0
        synthesizer.filterStrength        = 0.2
        synthesizer.vibratoDepth          = 0.03
    }

    // MARK: – Audio session observers

    func addObservers() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        #elseif os(macOS)
        // no route or interruption notifications on macOS
        #endif
    }

    @objc func handleRouteChange(notification: Notification) {
        #if os(iOS)
        guard
            let info       = notification.userInfo,
            let reasonRaw  = info[AVAudioSessionRouteChangeReasonKey] as? UInt
        else { return }

        switch reasonRaw {
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
        guard
            let info      = notification.userInfo,
            let typeRaw   = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type      = AVAudioSession.InterruptionType(rawValue: typeRaw)
        else { return }

        if type == .began {
            engine.stop()
        } else if
            type == .ended,
            let optionsRaw = info[AVAudioSessionInterruptionOptionKey] as? UInt,
            AVAudioSession.InterruptionOptions(rawValue: optionsRaw)
                .contains(.shouldResume)
        {
            reloadAudio()
        }
        #endif
    }
}
