import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var sessions: [WorkSession] = []
    
    init() {
        loadSessions()
    }
    
    func addSession(_ session: WorkSession) {
        sessions.append(session)
        saveSessions()
    }
    
    func deleteSession(_ session: WorkSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
    
    var todaySessions: [WorkSession] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return sessions.filter { $0.date >= today && $0.date < tomorrow }
    }
    
    var thisWeekSessions: [WorkSession] {
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())!
        return sessions.filter { weekInterval.contains($0.date) }
    }
    
    var thisMonthSessions: [WorkSession] {
        let calendar = Calendar.current
        let monthInterval = calendar.dateInterval(of: .month, for: Date())!
        return sessions.filter { monthInterval.contains($0.date) }
    }
    
    func totalDuration(for sessions: [WorkSession]) -> TimeInterval {
        return sessions.reduce(0) { $0 + $1.duration }
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "WorkSessions"),
           let decoded = try? JSONDecoder().decode([WorkSession].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "WorkSessions")
        }
    }
} 