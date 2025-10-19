# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StretchReminder is a macOS menu bar application built with Swift and SwiftUI. It provides periodic reminders to stand up and stretch, helping users maintain healthy work habits. The app runs as a status bar item (LSUIElement=true) and displays a fullscreen overlay when it's time to take a break.

## Build Commands

### Development Build
```bash
swift build
```

### Release Build and App Bundle Creation
```bash
./build-app.sh
```

This script:
1. Builds the Swift package in release mode (`swift build -c release`)
2. Creates a complete macOS app bundle at `build/StretchReminder.app`
3. Copies the executable to `Contents/MacOS/`
4. Copies `Info.plist` to `Contents/`
5. Generates app icons programmatically and creates an `.icns` file
6. Sets executable permissions
7. Code signs the app (if codesigning identity exists)

### Running the App
```bash
# Run from command line
swift run

# Run the built app bundle
open build/StretchReminder.app

# Install to Applications folder
cp -r build/StretchReminder.app /Applications/
```

## Architecture

### App Structure
The app follows a typical macOS menu bar app architecture:

- **Entry Point** (`StretchReminder.swift`): Sets up NSApplication with custom AppDelegate
- **AppDelegate** (`AppDelegate.swift`): Main coordinator that manages:
  - Status bar item with SF Symbol icon (`figure.wave`)
  - Popover for settings UI
  - TimerManager instance
  - BreakReminderWindow lifecycle
  - Sets activation policy to `.accessory` (menu bar only, no dock icon)

### Core Components

**TimerManager** (`Models/TimerManager.swift`):
- ObservableObject managing timer state and business logic
- Supports preset intervals (20, 40, 50 minutes) via `TimerPreset` enum
- Supports custom intervals with validation (1-999 minutes)
- Timer states: running, paused, stopped
- Persists settings to UserDefaults (selected preset, custom mode, custom minutes)
- Uses `Timer.scheduledTimer` with 0.1s tolerance for accuracy
- Calls `onTimerComplete` closure when timer reaches zero

**SettingsView** (`Views/SettingsView.swift`):
- SwiftUI view displayed in popover (340×550)
- Shows circular progress ring indicating time remaining
- Preset buttons for quick selection (20, 40, 50 minutes)
- Custom timer input field with real-time validation
- Control buttons: Start/Pause, Stop, Quit App
- Uses muted teal colors throughout for visual consistency
- Background uses `VisualEffectView` (NSVisualEffectView with `.hudWindow` material)

**BreakReminderWindow** (`Utilities/BreakReminderWindow.swift`):
- Custom NSWindow subclass for fullscreen break notifications
- Borderless, fullscreen window with semi-transparent black background (alpha 0.7)
- Window level: `.floating + 1000` to stay on top of all windows
- Supports ESC and Space key dismissal
- Fade in/out animations (0.3s duration)
- Plays system beep sound on appearance
- Contains `BreakReminderView` SwiftUI view with animated emoji rotation
- Auto-restarts timer on dismiss via closure callback

### Data Flow

1. User interacts with SettingsView (select preset or set custom time)
2. TimerManager updates `@Published` properties, triggering view updates
3. Settings changes persist to UserDefaults automatically
4. When timer completes, TimerManager calls `onTimerComplete` closure
5. AppDelegate receives callback and creates/shows BreakReminderWindow
6. Window dismissal triggers timer restart via closure callback

### Key Technical Details

- **macOS Version**: Requires macOS 12.0+ (specified in Package.swift and Info.plist)
- **Bundle ID**: `com.personal.StretchReminder`
- **App Category**: Productivity (`public.app-category.productivity`)
- **UI Framework**: SwiftUI with AppKit integration (NSStatusItem, NSPopover, NSWindow)
- **No External Dependencies**: Pure Swift Package Manager project

### Timer Accuracy
The timer uses `Timer.scheduledTimer` with 1-second intervals and 0.1-second tolerance. Time calculation is based on elapsed time from `startTime` rather than counting ticks, ensuring accuracy even if timer events are slightly delayed.

### Window Behavior
- **Status Bar Popover**: `.transient` behavior (auto-closes when clicking outside)
- **Break Reminder**: Fullscreen overlay with `.canJoinAllSpaces` and `.fullScreenAuxiliary` collection behaviors, ensuring visibility across all spaces and fullscreen apps
