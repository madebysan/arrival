import SwiftUI

@main
struct SubwayBarApp: App {
    @ObservedObject private var settings = SettingsManager.shared

    var body: some Scene {
        MenuBarExtra {
            ContentSwitcher()
        } label: {
            MenuBarLabel(route: settings.selectedRoute)
        }
        .menuBarExtraStyle(.window)
    }
}

// Switches between arrivals view and settings view inside the same popover
struct ContentSwitcher: View {
    @State private var showSettings = false

    var body: some View {
        Group {
            if showSettings {
                SettingsView(onDone: {
                    showSettings = false
                })
                .frame(width: 340, height: 480)
            } else {
                ArrivalView(onOpenSettings: {
                    showSettings = true
                })
                .frame(width: 300)
            }
        }
    }
}

// The menu bar label showing a colored subway bullet
struct MenuBarLabel: View {
    let route: String

    var body: some View {
        Image(nsImage: SubwayIcon.menuBarIcon(route: route, size: 18))
    }
}
