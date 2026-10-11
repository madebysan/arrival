import AppIntents
import WidgetKit

// AppIntent that lets the user pick which saved stop to show in the widget
struct SelectStopIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Stop"
    static var description = IntentDescription("Choose which subway stop to display.")

    @Parameter(title: "Stop")
    var stop: StopEntity?
}

// Wraps a TrackedStop as an AppEntity for the widget configuration picker
struct StopEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Stop")
    static var defaultQuery = StopEntityQuery()

    var id: String
    var route: String
    var stationName: String
    var direction: String

    var displayRepresentation: DisplayRepresentation {
        let dirLabel = direction == "N" ? "Uptown" : "Downtown"
        return DisplayRepresentation(title: "\(route) at \(stationName) (\(dirLabel))")
    }
}

// Provides the list of saved stops for the configuration picker
// Reads directly from App Group UserDefaults to avoid @Observable issues in extension context
struct StopEntityQuery: EnumerableEntityQuery {

    // Read stops straight from the shared App Group container
    private func loadStops() -> [TrackedStop] {
        guard let defaults = UserDefaults(suiteName: StopManager.appGroupID),
              let data = defaults.data(forKey: "trackedStops"),
              let stops = try? JSONDecoder().decode([TrackedStop].self, from: data) else {
            return []
        }
        return stops
    }

    func entities(for identifiers: [String]) async throws -> [StopEntity] {
        let stops = loadStops()
        return identifiers.compactMap { id in
            guard let stop = stops.first(where: { $0.id.uuidString == id }) else { return nil }
            return StopEntity(
                id: stop.id.uuidString,
                route: stop.route,
                stationName: stop.stationName,
                direction: stop.direction
            )
        }
    }

    func allEntities() async throws -> [StopEntity] {
        loadStops().map { stop in
            StopEntity(
                id: stop.id.uuidString,
                route: stop.route,
                stationName: stop.stationName,
                direction: stop.direction
            )
        }
    }

    func suggestedEntities() async throws -> [StopEntity] {
        try await allEntities()
    }

    func defaultResult() async -> StopEntity? {
        guard let first = loadStops().first else { return nil }
        return StopEntity(
            id: first.id.uuidString,
            route: first.route,
            stationName: first.stationName,
            direction: first.direction
        )
    }
}
