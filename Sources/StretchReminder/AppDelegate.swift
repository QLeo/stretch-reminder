import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timerManager: TimerManager!
    private var reminderWindow: BreakReminderWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Don't show in Dock (menu bar app only)
        NSApp.setActivationPolicy(.accessory)

        // Initialize TimerManager
        timerManager = TimerManager()
        timerManager.onTimerComplete = { [weak self] in
            self?.showBreakReminder()
        }

        // Setup menu bar item
        setupStatusItem()

        // Setup popover
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "figure.walk", accessibilityDescription: "Stretch Reminder")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 450)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: SettingsView(timerManager: timerManager))
    }

    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    private func showBreakReminder() {
        // Ignore if window is already showing
        if reminderWindow != nil && reminderWindow!.isVisible {
            return
        }

        // Create and show reminder window
        DispatchQueue.main.async { [weak self] in
            self?.reminderWindow = BreakReminderWindow()
            self?.reminderWindow?.onDismiss = { [weak self] in
                self?.reminderWindow = nil
                self?.timerManager.startTimer() // Restart timer
            }
            self?.reminderWindow?.show()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup on app termination
        timerManager.stopTimer()
    }
}