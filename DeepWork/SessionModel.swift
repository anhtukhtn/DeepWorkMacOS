import Foundation

struct WorkSession: Identifiable, Codable {
    let id: UUID
    let title: String
    let duration: TimeInterval
    let date: Date
    
    init(title: String, duration: TimeInterval, date: Date) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.date = date
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct AppSettings: Codable {
    var maxCount: TimeInterval = 7200 // 2 hours default
    var backgroundColor: String = "blue"
    var volume: Double = 0.5
    var defaultTitle: String = "Deep Work Session"
} 