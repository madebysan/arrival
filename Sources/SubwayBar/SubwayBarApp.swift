import SwiftUI

@main
struct SubwayBarApp: App {
    @ObservedObject private var settings = SettingsManager.shared

    var body: some Scene {
        MenuBarExtra {
            ArrivalView()
        } label: {
            MenuBarLabel(route: settings.selectedRoute)
        }
        .menuBarExtraStyle(.window)
    }
}

// The menu bar label showing a colored subway bullet
struct MenuBarLabel: View {
    let route: String

    var body: some View {
        // For menu bar, we use an Image created from NSImage
        // because MenuBarExtra label needs to be lightweight
        Image(nsImage: SubwayIcon.menuBarIcon(route: route, size: 18))
    }
}
