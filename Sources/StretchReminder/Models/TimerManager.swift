import Foundation
import Combine

enum TimerPreset: Int, CaseIterable {
    case twenty = 20
    case forty = 40
    case fifty = 50

    var displayName: String {
        return "\(rawValue)m"
    }

    var seconds: TimeInterval {
        return TimeInterval(rawValue * 60)
    }
}

class TimerManager: ObservableObject {
    @Published var selectedPreset: TimerPreset? = .twenty {
        didSet {
            saveSettings()
            if isRunning {
                restartTimer()
            }
        }
    }

    @Published var isCustomMode: Bool = false {
        didSet {
            saveSettings()
            if isRunning {
                restartTimer()
            }
        }
    }

    @Published var customMinutes: Int = 25 {
        didSet {
            saveSettings()
            if isRunning && isCustomMode {
                restartTimer()
            }
        }
    }

    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false

    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0

    // Closure called when timer completes
    var onTimerComplete: (() -> Void)?

    // Current duration in minutes
    var currentMinutes: Int {
        return isCustomMode ? customMinutes : (selectedPreset?.rawValue ?? 20)
    }

    // Current duration in seconds
    var currentSeconds: TimeInterval {
        return TimeInterval(currentMinutes * 60)
    }

    init() {
        loadSettings()
        resetTimer()
    }

    // MARK: - Timer Control

    func startTimer() {
        guard !isRunning else { return }

        isRunning = true
        isPaused = false
        startTime = Date()
        pausedTime = 0
        timeRemaining = currentSeconds

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }

        // Improve timer accuracy
        timer?.tolerance = 0.1
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        resetTimer()
    }

    func pauseTimer() {
        guard isRunning && !isPaused else { return }

        isPaused = true
        pausedTime = timeRemaining
        timer?.invalidate()
    }

    func resumeTimer() {
        guard isRunning && isPaused else { return }

        isPaused = false
        timeRemaining = pausedTime
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        timer?.tolerance = 0.1
    }

    func resetTimer() {
        timeRemaining = currentSeconds
    }

    private func restartTimer() {
        stopTimer()
        startTimer()
    }

    private func updateTimer() {
        guard isRunning && !isPaused else { return }

        if let startTime = startTime {
            let elapsed = Date().timeIntervalSince(startTime)
            let totalTime = isPaused ? pausedTime : currentSeconds
            timeRemaining = max(0, totalTime - elapsed)

            if timeRemaining <= 0 {
                timerCompleted()
            }
        }
    }

    private func timerCompleted() {
        stopTimer()
        onTimerComplete?()
    }

    // MARK: - Persistence

    private func saveSettings() {
        UserDefaults.standard.set(isCustomMode, forKey: "isCustomMode")
        UserDefaults.standard.set(customMinutes, forKey: "customMinutes")
        if let preset = selectedPreset {
            UserDefaults.standard.set(preset.rawValue, forKey: "selectedTimerPreset")
        }
    }

    private func loadSettings() {
        isCustomMode = UserDefaults.standard.bool(forKey: "isCustomMode")
        let savedCustom = UserDefaults.standard.integer(forKey: "customMinutes")
        if savedCustom > 0 {
            customMinutes = savedCustom
        }
        let savedValue = UserDefaults.standard.integer(forKey: "selectedTimerPreset")
        if let preset = TimerPreset(rawValue: savedValue) {
            selectedPreset = preset
        }
    }

    // MARK: - Formatting

    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        let total = currentSeconds
        return total > 0 ? (total - timeRemaining) / total : 0
    }
}