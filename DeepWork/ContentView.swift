import SwiftUI

struct ContentView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var showingSettings = false
    @State private var showingHistory = false
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.bottom, 16)
                
                timerDisplay
                    .padding(.bottom, 32)
                
                controlButtons
                    .padding(.bottom, 24)
                
                progressBar
            }
            .padding(24)
        }
        .frame(width: 360, height: 360)
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                settings: timerViewModel.settings,
                onSave: { newSettings in
                    timerViewModel.updateSettings(newSettings)
                }
            )
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(historyViewModel: historyViewModel)
        }
    }
    
    private var backgroundColor: Color {
        switch timerViewModel.settings.backgroundColor {
        case "blue": return Color.blue.opacity(0.08)
        case "green": return Color.green.opacity(0.08)
        case "purple": return Color.purple.opacity(0.08)
        case "orange": return Color.orange.opacity(0.08)
        default: return Color.blue.opacity(0.08)
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    showingHistory = true
                }) {
                    Text("History")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(minWidth: 30, minHeight: 32)
                        .padding(.horizontal, 0)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                
                Button(action: {
                    showingSettings = true
                }) {
                    Text("Settings")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(minWidth: 30, minHeight: 32)
                        .padding(.horizontal, 0)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 16) {
            TextField("Session Title", text: $timerViewModel.sessionTitle)
                .textFieldStyle(.plain)
                .font(.callout)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
                .padding(.horizontal, 32)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Text(timerViewModel.formattedTime)
                .font(.system(size: 56, design: .monospaced))
                .fontWeight(.light)
                .foregroundColor(timerViewModel.isMaxReached ? .red : .black)
                .padding(.vertical, 8)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                if timerViewModel.state == .running {
                    timerViewModel.pauseTimer()
                } else if timerViewModel.state == .paused {
                    timerViewModel.resumeTimer()
                } else {
                    timerViewModel.startTimer()
                }
            }) {
                Text(buttonTitle)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 32)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .disabled(timerViewModel.isMaxReached && timerViewModel.state != .running)
            
            Button(action: {
                if timerViewModel.currentTime > 0 {
                    let session = timerViewModel.saveSession()
                    historyViewModel.addSession(session)
                }
                timerViewModel.restartTimer()
            }) {
                Text("Restart")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 70, height: 32)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }
    
    private var buttonTitle: String {
        switch timerViewModel.state {
        case .stopped: return "Start"
        case .running: return "Pause"
        case .paused: return "Resume"
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Progress")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Max: \(formattedMaxTime)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: timerViewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: accentColor.opacity(0.2)))
                .scaleEffect(x: 1, y: 1.2, anchor: .center)
        }
    }
    
    private var accentColor: Color {
        switch timerViewModel.settings.backgroundColor {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
    
    private var formattedMaxTime: String {
        let maxCount = timerViewModel.settings.maxCount
        let hours = Int(maxCount) / 3600
        let minutes = Int(maxCount) % 3600 / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

#Preview {
    ContentView()
} 