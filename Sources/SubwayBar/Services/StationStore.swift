import Foundation

// Loads and parses the bundled stops.txt file to provide station data
class StationStore: ObservableObject {

    static let shared = StationStore()

    @Published var stations: [Station] = []

    private init() {
        loadStations()
    }

    // Parse stops.txt from the app bundle
    private func loadStations() {
        guard let url = Bundle.module.url(forResource: "stops", withExtension: "txt") else {
            print("StationStore: Could not find stops.txt in bundle")
            return
        }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("StationStore: Could not read stops.txt")
            return
        }

        let lines = content.components(separatedBy: .newlines)
        guard lines.count > 1 else { return }

        // Parse header to find column indices
        let header = lines[0].components(separatedBy: ",")
        guard let stopIDIndex = header.firstIndex(of: "stop_id"),
              let nameIndex = header.firstIndex(of: "stop_name"),
              let latIndex = header.firstIndex(of: "stop_lat"),
              let lonIndex = header.firstIndex(of: "stop_lon"),
              let locationTypeIndex = header.firstIndex(of: "location_type"),
              let parentIndex = header.firstIndex(of: "parent_station") else {
            print("StationStore: Unexpected stops.txt header format")
            return
        }

        // First pass: collect parent stations
        var parentStations: [String: (name: String, lat: Double, lon: Double)] = [:]
        // Second pass: collect child stops (N/S platforms)
        var childStops: [String: [String]] = [:] // parent_id -> [child_stop_ids]

        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }

            let fields = line.components(separatedBy: ",")
            guard fields.count > max(stopIDIndex, nameIndex, latIndex, lonIndex, locationTypeIndex, parentIndex) else {
                continue
            }

            let stopID = fields[stopIDIndex]
            let name = fields[nameIndex]
            let lat = Double(fields[latIndex]) ?? 0
            let lon = Double(fields[lonIndex]) ?? 0
            let locationType = fields[locationTypeIndex]
            let parentStation = fields[parentIndex]

            if locationType == "1" || parentStation.isEmpty {
                // This is a parent station
                if locationType == "1" {
                    parentStations[stopID] = (name: name, lat: lat, lon: lon)
                }
            } else {
                // This is a child platform stop
                if childStops[parentStation] == nil {
                    childStops[parentStation] = []
                }
                childStops[parentStation]?.append(stopID)
            }
        }

        // Build station objects
        var result: [Station] = []
        for (id, info) in parentStations {
            let children = childStops[id] ?? []
            let northStop = children.first { $0.hasSuffix("N") }
            let southStop = children.first { $0.hasSuffix("S") }

            let station = Station(
                id: id,
                name: info.name,
                latitude: info.lat,
                longitude: info.lon,
                northStopID: northStop,
                southStopID: southStop
            )
            result.append(station)
        }

        // Sort alphabetically by name
        self.stations = result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // Search stations by name
    func search(query: String) -> [Station] {
        if query.isEmpty { return stations }
        let lowered = query.lowercased()
        return stations.filter { $0.name.lowercased().contains(lowered) }
    }

    // Find a station by its parent stop_id
    func station(byID id: String) -> Station? {
        return stations.first { $0.id == id }
    }
}
