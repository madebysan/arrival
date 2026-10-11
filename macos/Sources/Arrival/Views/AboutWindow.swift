import SwiftUI
import AppKit

// Floating About window — singleton, shown via AboutWindow.show()
final class AboutWindow {
    private static var window: NSWindow?

    static func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingView = NSHostingView(rootView: AboutContentView())
        hostingView.frame = NSRect(x: 0, y: 0, width: 280, height: 320)

        let w = NSPanel(
            contentRect: hostingView.frame,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        w.titlebarAppearsTransparent = true
        w.titleVisibility = .hidden
        w.isMovableByWindowBackground = true
        w.contentView = hostingView
        w.center()
        w.isFloatingPanel = true
        w.level = .floating
        w.isReleasedWhenClosed = false

        window = w
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - SwiftUI Content

private struct AboutContentView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 8)

            // App icon
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            // App name
            Text("Arrival")
                .font(.title2)
                .fontWeight(.semibold)

            // Description
            Text("Real-time NYC subway arrivals\nin your menu bar.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Version
            Text("Version \(version)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()
                .padding(.horizontal, 32)

            // Credit link
            MadeByLink()

            Spacer()
        }
        .frame(width: 280, height: 320)
    }
}

// "Made by santiagoalonso.com" — "Made by" in secondary, link in accent
private struct MadeByLink: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("Made by")
                .font(.caption)
                .foregroundColor(.secondary)
            Button("santiagoalonso.com") {
                if let url = URL(string: "https://santiagoalonso.com") {
                    NSWorkspace.shared.open(url)
                }
            }
            .font(.caption)
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .underline()
        }
    }
}
