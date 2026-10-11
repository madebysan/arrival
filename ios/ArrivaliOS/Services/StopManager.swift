import Foundation

// Manages saved stops (replaces macOS SettingsManager)
// Uses @Observable (iOS 17+) for SwiftUI integration
// Data stored in App Group so the widget extension can read it
@Observable
class StopManager {
    static let shared = StopManager()
    static let appGroupID = "group.com.santiagoalonso.ArrivaliOS"

    var stops: [TrackedStop] = []

    // Max number of saved stops
    static let maxStops = 4

    private let userDefaultsKey = "trackedStops"
    private let defaults: UserDefaults

    private init() {
        self.defaults = UserDefaults(suiteName: Self.appGroupID) ?? .standard
        migrateFromStandardDefaults()
        loadStops()
        // Re-save to ensure data is flushed to the App Group container
        if !stops.isEmpty {
            saveStops()
        }
    }

    // Migrate stops from UserDefaults.standard to the App Group container
    // This handles cases where stops were saved before App Group was provisioned
    private func migrateFromStandardDefaults() {
        // If App Group already has data, skip
        if defaults.data(forKey: userDefaultsKey) != nil { return }
        // Copy from .standard if it has data
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            defaults.set(data, forKey: userDefaultsKey)
            defaults.synchronize()
            // Only remove from .standard if the write succeeded
            if defaults.data(forKey: userDefaultsKey) != nil {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }

    // Whether the user has any saved stops
    var hasStops: Bool {
        !stops.isEmpty
    }

    // Whether the user can add more stops
    var canAddStop: Bool {
        stops.count < Self.maxStops
    }

    // Add a new tracked stop
    func addStop(_ stop: TrackedStop) {
        guard canAddStop else { return }

        // Don't add duplicates (same station + direction + route)
        let isDuplicate = stops.contains {
            $0.stationID == stop.stationID &&
            $0.direction == stop.direction &&
            $0.route == stop.route
        }
        guard !isDuplicate else { return }

        stops.append(stop)
        saveStops()
    }

    // Remove a stop by ID
    func removeStop(id: UUID) {
        stops.removeAll { $0.id == id }
        saveStops()
    }

    // Move stops (for reordering)
    func moveStop(from source: IndexSet, to destination: Int) {
        stops.move(fromOffsets: source, toOffset: destination)
        saveStops()
    }

    // Update walking time for a stop
    func updateWalkingTime(id: UUID, minutes: Int) {
        if let index = stops.firstIndex(where: { $0.id == id }) {
            stops[index].walkingTimeMinutes = minutes
            saveStops()
        }
    }

    // MARK: - Persistence

    private func saveStops() {
        if let data = try? JSONEncoder().encode(stops) {
            defaults.set(data, forKey: userDefaultsKey)
            defaults.synchronize()
        }
    }

    private func loadStops() {
        guard let data = defaults.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([TrackedStop].self, from: data) else {
            return
        }
        stops = decoded
    }
}
