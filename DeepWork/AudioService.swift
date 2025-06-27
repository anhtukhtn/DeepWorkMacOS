import AVFoundation
import Foundation

class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    @Published var volume: Double = 0.5 {
        didSet {
            updateVolume()
        }
    }
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        // Replace "clock-ticking" with the actual filename you downloaded
        // Make sure the file extension matches (e.g., .mp3, .wav, .m4a)
        guard let soundURL = Bundle.main.url(forResource: "slow-cinematic-clock-ticking", withExtension: "mp3") else {
            print("Could not find slow-cinematic-clock-ticking.mp3 file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            updateVolume()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    private func updateVolume() {
        audioPlayer?.volume = Float(volume)
    }
    
    func startTicking() {
        audioPlayer?.play()
    }
    
    func stopTicking() {
        audioPlayer?.stop()
        // Reset to beginning for next play
        audioPlayer?.currentTime = 0
    }
    
    func setVolume(_ newVolume: Double) {
        volume = newVolume
    }
} 