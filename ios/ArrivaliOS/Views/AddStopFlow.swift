import SwiftUI

// Sheet: line picker -> direction + walking time -> station picker -> save
struct AddStopFlow: View {
    var onSave: (TrackedStop) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .linePicker
    @State private var selectedRoute = ""
    @State private var selectedDirection = "N"
    @State private var walkingTime = 5

    enum Step {
        case linePicker
        case directionPicker
        case stationPicker
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .linePicker:
                    linePickerContent
                case .directionPicker:
                    directionPickerContent
                case .stationPicker:
                    stationPickerContent
                }
            }
            .navigationTitle(titleForStep)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == .linePicker {
                        Button("Cancel") { dismiss() }
                    } else {
                        Button {
                            goBack()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Back")
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var titleForStep: String {
        switch step {
        case .linePicker: return "Pick a Line"
        case .directionPicker: return "Direction & Walk Time"
        case .stationPicker: return "Pick a Station"
        }
    }

    // MARK: - Line Picker

    // All subway lines grouped by color family
    private let lineGroups: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7"],
        ["A", "C", "E"],
        ["B", "D", "F", "M"],
        ["G"],
        ["J", "Z"],
        ["L"],
        ["N", "Q", "R", "W"],
        ["S"],
    ]

    private var linePickerContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Which train do you ride?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                ForEach(lineGroups, id: \.self) { group in
                    HStack(spacing: 12) {
                        ForEach(group, id: \.self) { route in
                            Button {
                                selectedRoute = route
                                step = .directionPicker
                            } label: {
                                SubwayBullet(route: route, size: 52)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Direction + Walking Time

    private var directionPickerContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Selected line
                HStack(spacing: 8) {
                    SubwayBullet(route: selectedRoute, size: 36)
                    Text("\(selectedRoute) train")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .padding(.top, 8)

                Text("Which direction?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Direction buttons
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

                Divider()
                    .padding(.top, 4)

                // Walking time
                VStack(alignment: .leading, spacing: 10) {
                    Text("Walking Time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("Minutes to station:")
                            .font(.body)
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                if walkingTime > 0 { walkingTime -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(walkingTime)")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.medium)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)

                            Button {
                                if walkingTime < 30 { walkingTime += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Text("Trains arriving within \(walkingTime) min show \"Leave now!\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func directionButton(direction: String, title: String, subtitle: String, icon: String) -> some View {
        Button {
            selectedDirection = direction
            step = .stationPicker
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(SubwayColors.color(for: selectedRoute))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Station Picker

    private var stationPickerContent: some View {
        StationPickerView(route: selectedRoute, direction: selectedDirection) { station in
            let newStop = TrackedStop(
                route: selectedRoute,
                stationID: station.id,
                stationName: station.name,
                direction: selectedDirection,
                walkingTimeMinutes: walkingTime
            )
            onSave(newStop)
        }
    }

    // MARK: - Navigation

    private func goBack() {
        switch step {
        case .linePicker: break
        case .directionPicker: step = .linePicker
        case .stationPicker: step = .directionPicker
        }
    }
}
