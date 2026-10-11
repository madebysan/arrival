import SwiftUI

@main
struct ArrivalApp: App {
    @State private var stopManager = StopManager.shared
    @AppStorage("appTheme") private var selectedTheme: String = AppTheme.system.rawValue

    private var colorScheme: ColorScheme? {
        (AppTheme(rawValue: selectedTheme) ?? .system).colorScheme
    }

    var body: some Scene {
        WindowGroup {
            HomeView(stopManager: stopManager)
                .preferredColorScheme(colorScheme)
        }
    }
}
