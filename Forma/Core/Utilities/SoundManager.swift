//
//  SoundManager.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/13/26.
//

import AVFoundation
import UIKit

final class SoundManager {
    
    // MARK: - Singleton
    static let shared = SoundManager()
    
    // MARK: - Properties
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    private var isSoundEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isSoundEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isSoundEnabled") }
    }
    
    private var soundVolume: Float {
        get { UserDefaults.standard.float(forKey: "soundVolume") }
        set { UserDefaults.standard.set(newValue, forKey: "soundVolume") }
    }
    
    // MARK: - Sound Effects Enum
    enum SoundEffect: String {
        // UI Interactions
        case buttonTap = "ui_tap_soft"
        
        // Notifications
        case notificationSuccess = "fx_success"
        case notificationError = "fx_error"
        case notificationInfo = "ntf_notification"
        
        var fileName: String {
            return rawValue
        }
        
        var fileExtension: String {
            return "mp3" // or "wav", "m4a" based on your files
        }
    }
    
    // MARK: - Initialization
    private init() {
        setupDefaultSettings()
        setupAudioSession()
        preloadSoundEffects()
    }
    
    private func setupDefaultSettings() {
        // Set defaults if not already set
        if UserDefaults.standard.object(forKey: "isSoundEnabled") == nil {
            isSoundEnabled = true
        }
        if UserDefaults.standard.object(forKey: "soundVolume") == nil {
            soundVolume = 0.7
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Preload Sound Effects
    private func preloadSoundEffects() {
        // Preload commonly used sounds for instant playback
        let commonSounds: [SoundEffect] = [
            .buttonTap,
            .notificationSuccess
        ]
        
        commonSounds.forEach { sound in
            _ = getAudioPlayer(for: sound)
        }
    }
    
    // MARK: - Get or Create Audio Player
    private func getAudioPlayer(for sound: SoundEffect) -> AVAudioPlayer? {
        // Return existing player if already loaded
        if let existingPlayer = soundEffectPlayers[sound] {
            return existingPlayer
        }
        
        // Create new player
        guard let url = Bundle.main.url(
            forResource: sound.fileName,
            withExtension: sound.fileExtension
        ) else {
            print("❌ Sound file not found: \(sound.fileName).\(sound.fileExtension)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = soundVolume
            soundEffectPlayers[sound] = player
            return player
        } catch {
            print("❌ Failed to create audio player: \(error)")
            return nil
        }
    }
    
    // MARK: - Play Sound Effect
    func playSound(_ sound: SoundEffect) {
        guard isSoundEnabled else { return }
        
        guard let player = getAudioPlayer(for: sound) else { return }
        
        player.volume = soundVolume
        player.currentTime = 0 // Reset to beginning
        
        DispatchQueue.main.async {
            player.play()
        }
    }
    
    
    // MARK: - Haptic Feedback (Bonus)
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        DispatchQueue.main.async {
            generator.impactOccurred()
        }
    }
    
    func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        DispatchQueue.main.async {
            generator.notificationOccurred(type)
        }
    }
    
    // MARK: - Settings
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        if !enabled {
            soundEffectPlayers.values.forEach { $0.stop() }
        }
    }
    
    func setSoundVolume(_ volume: Float) {
        soundVolume = max(0.0, min(1.0, volume))
        soundEffectPlayers.values.forEach { $0.volume = soundVolume }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        soundEffectPlayers.values.forEach { $0.stop() }
        soundEffectPlayers.removeAll()
    }
}
