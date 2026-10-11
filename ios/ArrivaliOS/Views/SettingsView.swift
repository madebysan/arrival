import SwiftUI

// Appearance preference stored in UserDefaults
enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// Settings screen with theme picker and About info
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var selectedTheme: String = AppTheme.system.rawValue

    private var theme: AppTheme {
        AppTheme(rawValue: selectedTheme) ?? .system
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance
                Section {
                    let options = AppTheme.allCases
                    ForEach(options, id: \.rawValue) { option in
                        Button {
                            selectedTheme = option.rawValue
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: option.icon)
                                    .foregroundStyle(option == .dark ? Color.purple : Color.orange)
                                    .frame(width: 24)

                                Text(option.label)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if theme == option {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose how Arrival looks. System follows your device setting.")
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        if let url = URL(string: "https://santiagoalonso.com") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Made by")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("santiagoalonso.com")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
