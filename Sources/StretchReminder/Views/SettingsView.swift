import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var hoveredPreset: TimerPreset? = nil
    @State private var customInputText: String = ""
    @State private var isCustomHovered: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Stretch Reminder")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            // Timer display
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: timerManager.progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut(duration: 0.5), value: timerManager.progress)

                VStack {
                    Text(timerManager.formattedTimeRemaining)
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)

                    Text(timerManager.isRunning ? (timerManager.isPaused ? "Paused" : "Running") : "Stopped")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Preset selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Timer Settings")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    ForEach(TimerPreset.allCases, id: \.self) { preset in
                        PresetButton(
                            preset: preset,
                            isSelected: !timerManager.isCustomMode && timerManager.selectedPreset == preset,
                            isHovered: hoveredPreset == preset
                        ) {
                            timerManager.isCustomMode = false
                            timerManager.selectedPreset = preset
                        } onHover: { hovering in
                            hoveredPreset = hovering ? preset : nil
                        }
                    }

                    // Custom button
                    Button(action: {
                        timerManager.isCustomMode = true
                        customInputText = "\(timerManager.customMinutes)"
                    }) {
                        Text("Custom")
                            .font(.system(size: 13, weight: timerManager.isCustomMode ? .semibold : .regular))
                            .foregroundColor(timerManager.isCustomMode ? .white : .primary)
                            .frame(width: 60, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(timerManager.isCustomMode ? Color.accentColor : (isCustomHovered ? Color.gray.opacity(0.2) : Color.clear))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(timerManager.isCustomMode ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        isCustomHovered = hovering
                    }
                }

                // Custom time input
                if timerManager.isCustomMode {
                    HStack(spacing: 10) {
                        TextField("Minutes", text: $customInputText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 60)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                            .multilineTextAlignment(.center)
                            .onChange(of: customInputText) { newValue in
                                if let minutes = Int(newValue), minutes > 0 && minutes <= 999 {
                                    timerManager.customMinutes = minutes
                                }
                            }

                        Text("minutes")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(.top, 5)
                }
            }
            .padding(.horizontal, 10)

            // Control buttons
            HStack(spacing: 15) {
                // Start/Pause button
                Button(action: {
                    if timerManager.isRunning {
                        if timerManager.isPaused {
                            timerManager.resumeTimer()
                        } else {
                            timerManager.pauseTimer()
                        }
                    } else {
                        timerManager.startTimer()
                    }
                }) {
                    HStack {
                        Image(systemName: timerManager.isRunning ? (timerManager.isPaused ? "play.fill" : "pause.fill") : "play.fill")
                        Text(timerManager.isRunning ? (timerManager.isPaused ? "Resume" : "Pause") : "Start")
                    }
                    .frame(width: 100)
                }
                .buttonStyle(PrimaryButtonStyle())

                // Stop button
                Button(action: {
                    timerManager.stopTimer()
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .frame(width: 80)
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(!timerManager.isRunning)
            }

            Divider()

            // Quit button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit App")
                }
                .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .frame(width: 300, height: 450)
        .background(VisualEffectView())
        .onAppear {
            customInputText = "\(timerManager.customMinutes)"
        }
    }
}

// Preset button component
struct PresetButton: View {
    let preset: TimerPreset
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: action) {
            Text(preset.displayName)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 50, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : (isHovered ? Color.gray.opacity(0.2) : Color.clear))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover(perform: onHover)
    }
}

// Button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isEnabled ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isEnabled ? .primary : .secondary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

// Translucent background effect
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}