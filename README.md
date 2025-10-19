# 🤸 Stretch Reminder

A macOS menu bar app to help you maintain healthy work habits with periodic stretch reminders.

## Introduction

Stretch Reminder is a simple menu bar application designed for people who sit and work for extended periods. It displays fullscreen notifications at configured intervals, encouraging you to take breaks and stretch, helping you maintain healthy work habits.

## Key Features

- **Menu Bar Integration**: Clean interface that lives in the menu bar only, without a Dock icon
- **Flexible Timer Settings**:
  - Quick presets: 20, 40, or 50 minutes
  - Custom intervals: Set any duration from 1 to 999 minutes
- **Visual Feedback**:
  - Circular progress ring showing remaining time
  - Clear timer state indicators (running/paused/stopped)
- **Fullscreen Notifications**: When time is up, a fullscreen reminder appears
- **Easy Controls**:
  - Start/Pause/Stop functionality
  - Dismiss notifications with ESC or Spacebar
  - Works across all virtual desktops
- **Persistent Settings**: Your timer preferences are automatically saved

## System Requirements

- macOS 12.0 (Monterey) or later
- Apple Silicon or Intel Mac

## Installation

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stretch-reminder.git
cd stretch-reminder
```

2. Build the app:
```bash
./build-app.sh
```

3. Run the app:
```bash
open build/StretchReminder.app
```

4. (Optional) Install to Applications folder:
```bash
cp -r build/StretchReminder.app /Applications/
```

## Usage

### Getting Started

1. **Launch the App**: When you run StretchReminder, a 🙋 icon appears in your menu bar
2. **Open Settings**: Click the menu bar icon to open the timer settings window
3. **Configure Timer**:
   - Select one of the quick preset buttons (20, 40, or 50 minutes), or
   - Choose "Custom" and enter your desired time
4. **Start Timer**: Click the "Start" button to begin the timer
5. **Receive Notifications**: When the timer completes, a fullscreen reminder appears

### Timer Controls

- **Start**: Click Start button to begin the timer
- **Pause**: Click Pause button to pause the timer
- **Resume**: Click Resume button to continue a paused timer
- **Stop**: Click Stop button to stop and reset the timer

### Dismissing Notifications

When a stretch reminder appears, you can dismiss it by:
- Pressing **ESC** or **Spacebar**
- Clicking anywhere on the screen
- Clicking the "OK" button

The timer automatically restarts after dismissing a notification.

## Development

### Building

```bash
# Development build
swift build

# Release build
swift build -c release

# Create app bundle
./build-app.sh
```

### Project Structure

```
Sources/StretchReminder/
├── StretchReminder.swift          # App entry point
├── AppDelegate.swift              # App delegate (menu bar, timer management)
├── Models/
│   └── TimerManager.swift         # Timer logic and state management
├── Views/
│   └── SettingsView.swift         # Settings UI (SwiftUI)
└── Utilities/
    └── BreakReminderWindow.swift  # Fullscreen notification window
```

### Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI + AppKit
- **Build System**: Swift Package Manager
- **Dependencies**: None (pure Swift standard library)

## License

This is a personal project.

## Contributing

Feel free to open issues for improvements or bug reports!

---

**Work healthy! 💪**
