import SwiftUI

// Searchable station list, filtered by route
struct StationPickerView: View {
    @ObservedObject var stationStore = StationStore.shared
    @State private var searchText = ""

    let route: String
    let onSelect: (Station) -> Void

    private var filteredStations: [Station] {
        stationStore.search(query: searchText, route: route)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search stations...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.body)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Station count
            Text("\(filteredStations.count) stations on the \(route) line")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)

            // Station list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredStations) { station in
                        Button(action: {
                            onSelect(station)
                        }) {
                            HStack(spacing: 10) {
                                SubwayIcon.BulletView(route: route, size: 20)

                                Text(station.name)
                                    .font(.body)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(HighlightButtonStyle())

                        if station.id != filteredStations.last?.id {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }
}

// A button style that highlights the full row on hover/press
struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.3)
                    : Color.clear
            )
    }
}

// Helper to use NSColor as SwiftUI Color
extension Color {
    static let tertiaryLabelColor = Color(nsColor: .tertiaryLabelColor)
}
