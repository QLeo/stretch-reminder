import Cocoa
import SwiftUI

class BreakReminderWindow: NSWindow {
    var onDismiss: (() -> Void)?

    init() {
        // Get full screen size
        guard let screen = NSScreen.main else {
            super.init(contentRect: .zero, styleMask: [], backing: .buffered, defer: false)
            return
        }

        // Initialize window
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Window configuration
        self.isOpaque = false
        self.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        self.level = .floating + 1000 // Top level
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isReleasedWhenClosed = false
        self.ignoresMouseEvents = false

        // Setup SwiftUI view
        let reminderView = BreakReminderView { [weak self] in
            self?.dismiss()
        }
        self.contentView = NSHostingView(rootView: reminderView)

        // Enable keyboard event handling
        self.makeFirstResponder(nil)
        self.acceptsMouseMovedEvents = true
    }

    func show() {
        // Fade in animation
        self.alphaValue = 0
        self.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            self.animator().alphaValue = 1.0
        })

        // Play system sound
        NSSound.beep()
    }

    func dismiss() {
        // Fade out animation
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            self.animator().alphaValue = 0
        }) { [weak self] in
            self?.orderOut(nil)
            self?.onDismiss?()
        }
    }

    // Allow borderless window to become key window (to receive keyboard events)
    override var canBecomeKey: Bool {
        return true
    }

    // Handle ESC key
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC key
            dismiss()
        } else if event.keyCode == 49 { // Space key
            dismiss()
        } else {
            super.keyDown(with: event)
        }
    }
}

// Reminder view UI
struct BreakReminderView: View {
    let onDismiss: () -> Void
    @State private var isAnimating = false
    @State private var currentEmoji = "🤸"

    let stretchEmojis = ["🤸", "🧘", "🏃", "💪", "🚶"]

    var body: some View {
        ZStack {
            // Background (tap to dismiss)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismiss()
                }

            // Center message box
            VStack(spacing: 30) {
                // Animated emoji
                Text(currentEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                // Main message
                VStack(spacing: 10) {
                    Text("Time to Stretch!")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Take a moment to stand up and move")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Buttons
                HStack(spacing: 20) {
                    // OK button
                    Button(action: onDismiss) {
                        Text("OK")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.teal.opacity(0.7))
                            .cornerRadius(22)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Keyboard shortcut hint
                Text("Press ESC or Space to close")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.teal.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            isAnimating = true
            // Emoji rotation animation
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                withAnimation {
                    if let currentIndex = stretchEmojis.firstIndex(of: currentEmoji) {
                        let nextIndex = (currentIndex + 1) % stretchEmojis.count
                        currentEmoji = stretchEmojis[nextIndex]
                    }
                }
            }
        }
    }
}