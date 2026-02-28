import SwiftUI

// Settings view with station picker, direction, and walking time
struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedStation: Station?
    @State private var selectedRoute: String = ""
    @State private var selectedDirection: String = "N"
    @State private var walkingTime: Int = 5
    @State private var step: SettingsStep = .stationPicker

    enum SettingsStep {
        case stationPicker
        case routePicker
        case directionPicker
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .opacity(step != .stationPicker ? 1 : 0)
                .disabled(step == .stationPicker)

                Spacer()

                Text(titleForStep)
                    .font(.headline)

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Content based on step
            switch step {
            case .stationPicker:
                stationPickerContent

            case .routePicker:
                routePickerContent

            case .directionPicker:
                directionAndWalkingContent
            }
        }
        .onAppear {
            walkingTime = settings.walkingTimeMinutes
        }
    }

    private var titleForStep: String {
        switch step {
        case .stationPicker:
            return "Pick a Station"
        case .routePicker:
            return "Pick a Line"
        case .directionPicker:
            return "Direction & Settings"
        }
    }

    // MARK: - Station Picker

    private var stationPickerContent: some View {
        StationPickerView { station in
            selectedStation = station
            let routes = station.inferredRoutes
            if routes.count == 1 {
                // Only one route, skip route picker
                selectedRoute = routes[0]
                step = .directionPicker
            } else {
                step = .routePicker
            }
        }
    }

    // MARK: - Route Picker

    private var routePickerContent: some View {
        VStack(spacing: 0) {
            if let station = selectedStation {
                Text(station.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                List(station.inferredRoutes, id: \.self) { route in
                    Button(action: {
                        selectedRoute = route
                        step = .directionPicker
                    }) {
                        HStack {
                            SubwayIcon.BulletView(route: route, size: 28)
                            Text("\(route) train")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Direction & Walking Time

    private var directionAndWalkingContent: some View {
        VStack(spacing: 16) {
            if let station = selectedStation {
                // Current selection summary
                HStack {
                    SubwayIcon.BulletView(route: selectedRoute, size: 28)
                    Text(station.name)
                        .font(.headline)
                }
                .padding(.top, 12)

                // Direction picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Direction")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Picker("Direction", selection: $selectedDirection) {
                        if station.northStopID != nil {
                            Text("Uptown / Manhattan-bound").tag("N")
                        }
                        if station.southStopID != nil {
                            Text("Downtown / Brooklyn-bound").tag("S")
                        }
                    }
                    .pickerStyle(.radioGroup)
                }
                .padding(.horizontal, 20)

                Divider()

                // Walking time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Walking Time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Minutes to station:")
                        Stepper("\(walkingTime)", value: $walkingTime, in: 0...30)
                            .frame(width: 100)
                    }

                    Text("Trains arriving within \(walkingTime) min will show \"Leave now!\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Save button
                Button(action: saveSettings) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Actions

    private func goBack() {
        switch step {
        case .stationPicker:
            break
        case .routePicker:
            step = .stationPicker
        case .directionPicker:
            if let station = selectedStation, station.inferredRoutes.count > 1 {
                step = .routePicker
            } else {
                step = .stationPicker
            }
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
        dismiss()
    }
}
