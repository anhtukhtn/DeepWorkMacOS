import Foundation
import Combine

enum TimerState {
    case stopped
    case running
    case paused
}

class TimerViewModel: ObservableObject {
    @Published var currentTime: TimeInterval = 0
    @Published var state: TimerState = .stopped
    @Published var sessionTitle: String = "Deep Work Session"
    @Published var settings = AppSettings()
    
    private var timer: Timer?
    private let audioService = AudioService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        setupAudioBinding()
    }
    
    private func setupAudioBinding() {
        $settings
            .map { $0.volume }
            .sink { [weak self] volume in
                self?.audioService.setVolume(volume)
            }
            .store(in: &cancellables)
    }
    
    var formattedTime: String {
        let hours = Int(currentTime) / 3600
        let minutes = Int(currentTime) % 3600 / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var progress: Double {
        guard settings.maxCount > 0 else { return 0 }
        return min(currentTime / settings.maxCount, 1.0)
    }
    
    var isMaxReached: Bool {
        return currentTime >= settings.maxCount
    }
    
    func startTimer() {
        guard state != .running else { return }
        
        state = .running
        audioService.startTicking()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentTime += 1
            
            if self.isMaxReached {
                self.pauseTimer()
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        state = .paused
        audioService.stopTicking()
    }
    
    func resumeTimer() {
        guard state == .paused else { return }
        startTimer()
    }
    
    func restartTimer() {
        timer?.invalidate()
        timer = nil
        currentTime = 0
        state = .stopped
        audioService.stopTicking()
    }
    
    func saveSession() -> WorkSession {
        return WorkSession(
            title: sessionTitle.isEmpty ? settings.defaultTitle : sessionTitle,
            duration: currentTime,
            date: Date()
        )
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveSettings()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "AppSettings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "AppSettings")
        }
    }
} 