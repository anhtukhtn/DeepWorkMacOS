import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: TimePeriod = .today
    
    enum TimePeriod: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Work History")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            // Period selector
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Statistics
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Sessions",
                    value: "\(currentSessions.count)",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Time",
                    value: historyViewModel.formattedDuration(totalDuration),
                    color: .green
                )
                
                StatCard(
                    title: "Average Session",
                    value: historyViewModel.formattedDuration(averageDuration),
                    color: .orange
                )
            }
            .padding(.horizontal)
            
            // Sessions list
            VStack(alignment: .leading, spacing: 10) {
                Text("Sessions")
                    .font(.headline)
                    .padding(.horizontal)
                
                if currentSessions.isEmpty {
                    Text("No sessions found for this period")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(currentSessions) { session in
                                SessionRow(session: session)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
        .frame(width: 500, height: 400)
    }
    
    private var currentSessions: [WorkSession] {
        switch selectedPeriod {
        case .today: return historyViewModel.todaySessions
        case .week: return historyViewModel.thisWeekSessions
        case .month: return historyViewModel.thisMonthSessions
        case .all: return historyViewModel.sessions
        }
    }
    
    private var totalDuration: TimeInterval {
        historyViewModel.totalDuration(for: currentSessions)
    }
    
    private var averageDuration: TimeInterval {
        guard !currentSessions.isEmpty else { return 0 }
        return totalDuration / Double(currentSessions.count)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SessionRow: View {
    let session: WorkSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(session.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(session.formattedDuration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}

#Preview {
    HistoryView(historyViewModel: HistoryViewModel())
} 