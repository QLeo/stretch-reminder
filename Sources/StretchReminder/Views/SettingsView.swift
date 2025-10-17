import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var hoveredPreset: TimerPreset? = nil
    @State private var customInputText: String = ""
    @State private var isCustomHovered: Bool = false
    @FocusState private var isCustomFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Header with icon
            HStack(spacing: 12) {
                Image(systemName: "figure.wave")
                    .font(.system(size: 28))
                    .foregroundColor(Color.teal.opacity(0.7))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Stretch Reminder")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Stay healthy, stay active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            // Timer display with muted colors
            VStack(spacing: 10) {
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            Color.teal.opacity(0.5),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 0.3), value: timerManager.progress)

                    VStack(spacing: 6) {
                        Text(timerManager.formattedTimeRemaining)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(timerManager.isRunning ? (timerManager.isPaused ? Color.orange.opacity(0.7) : Color.green.opacity(0.7)) : Color.gray.opacity(0.5))
                                .frame(width: 6, height: 6)

                            Text(timerManager.isRunning ? (timerManager.isPaused ? "Paused" : "Running") : "Stopped")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Current timer setting indicator
                Text("\(timerManager.currentMinutes) min interval")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            // Preset selection with muted colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Presets")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                // Preset buttons
                HStack(spacing: 8) {
                    ForEach(TimerPreset.allCases, id: \.self) { preset in
                        EnhancedPresetButton(
                            title: "\(preset.rawValue)",
                            subtitle: "min",
                            isSelected: !timerManager.isCustomMode && timerManager.selectedPreset == preset,
                            isHovered: hoveredPreset == preset
                        ) {
                            timerManager.isCustomMode = false
                            timerManager.selectedPreset = preset
                        } onHover: { hovering in
                            hoveredPreset = hovering ? preset : nil
                        }
                    }
                }

                // Custom option - single line
                Button(action: {
                    if !timerManager.isCustomMode {
                        timerManager.isCustomMode = true
                        isCustomFieldFocused = true
                        customInputText = "\(timerManager.customMinutes)"
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                            .foregroundColor(timerManager.isCustomMode ? .primary : .secondary)

                        Text("Custom")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(timerManager.isCustomMode ? .primary : .secondary)

                        if timerManager.isCustomMode {
                            TextField("", text: $customInputText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(width: 50)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(6)
                                .multilineTextAlignment(.center)
                                .focused($isCustomFieldFocused)
                                .onChange(of: customInputText) { newValue in
                                    if let minutes = Int(newValue), minutes > 0 && minutes <= 999 {
                                        timerManager.customMinutes = minutes
                                    }
                                }

                            Text("minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Set your own time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(timerManager.isCustomMode ? 0.12 : 0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(timerManager.isCustomMode ? 0.3 : 0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            // Control buttons with muted colors
            VStack(spacing: 10) {
                HStack(spacing: 10) {
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
                        HStack(spacing: 8) {
                            Image(systemName: timerManager.isRunning ? (timerManager.isPaused ? "play.fill" : "pause.fill") : "play.fill")
                                .font(.system(size: 14, weight: .semibold))

                            Text(timerManager.isRunning ? (timerManager.isPaused ? "Resume" : "Pause") : "Start")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .background(Color.teal.opacity(0.6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Stop button
                    Button(action: {
                        timerManager.stopTimer()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .foregroundColor(timerManager.isRunning ? .white : .secondary)
                            .background(timerManager.isRunning ? Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!timerManager.isRunning)
                }

                // Quit button
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "power")
                            .font(.system(size: 11))

                        Text("Quit App")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.red.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .frame(width: 340)
        .background(VisualEffectView())
        .onAppear {
            customInputText = "\(timerManager.customMinutes)"
        }
    }
}

// Enhanced preset button component with muted colors
struct EnhancedPresetButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.teal.opacity(0.15) : (isHovered ? Color.gray.opacity(0.12) : Color.gray.opacity(0.08)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.teal.opacity(0.4) : Color.gray.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover(perform: onHover)
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