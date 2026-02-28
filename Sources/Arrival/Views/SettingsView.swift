import SwiftUI

// Settings view: Line → Direction → Station (+ walking time)
struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    var onDone: () -> Void

    @State private var selectedRoute: String = ""
    @State private var selectedDirection: String = "N"
    @State private var selectedStation: Station?
    @State private var walkingTime: Int = 5
    @State private var step: SettingsStep = .linePicker

    enum SettingsStep {
        case linePicker
        case directionPicker
        case stationPicker
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                if step != .linePicker {
                    Button(action: goBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Back")
                                .font(.subheadline)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                } else {
                    Spacer().frame(width: 60)
                }

                Spacer()

                Text(titleForStep)
                    .font(.headline)

                Spacer()

                Button("Done") {
                    onDone()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Content based on step
            switch step {
            case .linePicker:
                linePickerContent

            case .directionPicker:
                directionPickerContent

            case .stationPicker:
                stationPickerContent
            }
        }
        .onAppear {
            walkingTime = settings.walkingTimeMinutes
        }
    }

    private var titleForStep: String {
        switch step {
        case .linePicker:
            return "Pick a Line"
        case .directionPicker:
            return "Pick Direction"
        case .stationPicker:
            return "Pick a Station"
        }
    }

    // MARK: - Line Picker (grid of subway bullets)

    // All subway lines grouped by color family
    private let lineGroups: [[String]] = [
        ["1", "2", "3"],           // Red
        ["4", "5", "6"],           // Green
        ["7"],                     // Purple
        ["A", "C", "E"],           // Blue
        ["B", "D", "F", "M"],      // Orange
        ["G"],                     // Light green
        ["J", "Z"],                // Brown
        ["L"],                     // Gray
        ["N", "Q", "R", "W"],      // Yellow
        ["S"],                     // Shuttle
    ]

    private var linePickerContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Which train do you ride?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)

                // Grid of line buttons grouped by color
                ForEach(lineGroups, id: \.self) { group in
                    HStack(spacing: 10) {
                        ForEach(group, id: \.self) { route in
                            Button(action: {
                                selectedRoute = route
                                step = .directionPicker
                            }) {
                                SubwayIcon.BulletView(route: route, size: 44)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 52, height: 52)
                            .contentShape(Rectangle())
                        }
                    }
                }

                Spacer().frame(height: 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Direction Picker

    private var directionPickerContent: some View {
        VStack(spacing: 16) {
            // Show selected line
            HStack(spacing: 8) {
                SubwayIcon.BulletView(route: selectedRoute, size: 36)
                Text("\(selectedRoute) train")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .padding(.top, 16)

            Text("Which direction?")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Two big direction buttons
            VStack(spacing: 10) {
                directionButton(
                    direction: "N",
                    title: "Uptown / Manhattan",
                    subtitle: "Northbound",
                    icon: "arrow.up"
                )

                directionButton(
                    direction: "S",
                    title: "Downtown / Brooklyn",
                    subtitle: "Southbound",
                    icon: "arrow.down"
                )
            }
            .padding(.horizontal, 16)

            // Walking time section
            Divider()
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("Walking Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Minutes to station:")
                        .font(.body)
                    Spacer()
                    HStack(spacing: 0) {
                        Button(action: { if walkingTime > 0 { walkingTime -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)

                        Text("\(walkingTime)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .frame(width: 36)
                            .multilineTextAlignment(.center)

                        Button(action: { if walkingTime < 30 { walkingTime += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("Trains arriving within \(walkingTime) min will show \"Leave now!\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    private func directionButton(direction: String, title: String, subtitle: String, icon: String) -> some View {
        Button(action: {
            selectedDirection = direction
            settings.walkingTimeMinutes = walkingTime
            step = .stationPicker
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(SubwayColors.color(for: selectedRoute))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(HighlightButtonStyle())
    }

    // MARK: - Station Picker (filtered by route)

    private var stationPickerContent: some View {
        StationPickerView(route: selectedRoute) { station in
            selectedStation = station
            saveSettings()
        }
    }

    // MARK: - Actions

    private func goBack() {
        switch step {
        case .linePicker:
            break
        case .directionPicker:
            step = .linePicker
        case .stationPicker:
            step = .directionPicker
        }
    }

    private func saveSettings() {
        guard let station = selectedStation else { return }
        settings.selectStation(
            id: station.id,
            name: station.name,
            route: selectedRoute,
            direction: selectedDirection
        )
        settings.walkingTimeMinutes = walkingTime
        onDone()
    }
}
