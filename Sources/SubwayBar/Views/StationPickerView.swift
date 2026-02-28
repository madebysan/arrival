import SwiftUI

// Searchable station list for picking a station
struct StationPickerView: View {
    @ObservedObject var stationStore = StationStore.shared
    @State private var searchText = ""
    let onSelect: (Station) -> Void

    private var filteredStations: [Station] {
        stationStore.search(query: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
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
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Station list
            List(filteredStations) { station in
                Button(action: {
                    onSelect(station)
                }) {
                    HStack {
                        // Show route bullets for this station
                        HStack(spacing: 2) {
                            ForEach(station.inferredRoutes, id: \.self) { route in
                                SubwayIcon.BulletView(route: route, size: 16)
                            }
                        }
                        .frame(minWidth: 40, alignment: .leading)

                        Text(station.name)
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
