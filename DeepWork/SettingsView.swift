import SwiftUI

struct SettingsView: View {
    @State private var localSettings: AppSettings
    let onSave: (AppSettings) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var maxHours: Int = 0
    @State private var maxMinutes: Int = 0
    
    init(settings: AppSettings, onSave: @escaping (AppSettings) -> Void) {
        self._localSettings = State(initialValue: settings)
        self.onSave = onSave
        self._maxHours = State(initialValue: Int(settings.maxCount) / 3600)
        self._maxMinutes = State(initialValue: Int(settings.maxCount) % 3600 / 60)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 10) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Save") {
                        updateMaxCount()
                        onSave(localSettings)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Timer Settings
                    GroupBox("Timer Settings") {
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Max Count Duration")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack(spacing: 8) {
                                    TextField("Hours", value: $maxHours, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 50)
                                    Text(":")
                                        .font(.title3)
                                    TextField("Minutes", value: $maxMinutes, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 50)
                                    Spacer()
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Default Session Title")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter title", text: $localSettings.defaultTitle)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(12)
                    }
                    
                    // Audio Settings
                    GroupBox("Audio Settings") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Volume: \(Int(localSettings.volume * 100))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Slider(value: $localSettings.volume, in: 0...1)
                        }
                        .padding(12)
                    }
                    
                    // Appearance
                    GroupBox("Appearance") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Background Color")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("Background Color", selection: $localSettings.backgroundColor) {
                                Text("Blue").tag("blue")
                                Text("Green").tag("green")
                                Text("Purple").tag("purple")
                                Text("Orange").tag("orange")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(12)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(width: 480, height: 450)
    }
    
    private func updateMaxCount() {
        localSettings.maxCount = TimeInterval(maxHours * 3600 + maxMinutes * 60)
    }
}

#Preview {
    SettingsView(settings: AppSettings()) { _ in }
} 