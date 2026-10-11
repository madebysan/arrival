import WidgetKit

// Timeline entry holding arrival data for a specific point in time
struct ArrivalEntry: TimelineEntry {
    let date: Date
    let stop: TrackedStop?
    let arrivals: [Arrival]
    let fetchedAt: Date
    let isPlaceholder: Bool
}

// Fetches MTA data and builds a timeline of entries for the widget
struct ArrivalTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = ArrivalEntry
    typealias Intent = SelectStopIntent

    // Placeholder shown while the widget loads (redacted skeleton)
    func placeholder(in context: Context) -> ArrivalEntry {
        ArrivalEntry(
            date: .now,
            stop: TrackedStop(
                route: "F",
                stationID: "F25",
                stationName: "15 St-Prospect Park",
                direction: "N",
                walkingTimeMinutes: 5
            ),
            arrivals: [
                Arrival(route: "F", destination: "Jamaica-179 St", arrivalTime: Date().addingTimeInterval(180)),
                Arrival(route: "F", destination: "Jamaica-179 St", arrivalTime: Date().addingTimeInterval(480)),
                Arrival(route: "F", destination: "Jamaica-179 St", arrivalTime: Date().addingTimeInterval(780)),
            ],
            fetchedAt: .now,
            isPlaceholder: true
        )
    }

    // Snapshot for widget gallery preview
    func snapshot(for configuration: SelectStopIntent, in context: Context) async -> ArrivalEntry {
        if context.isPreview {
            return placeholder(in: context)
        }
        return await fetchEntry(for: configuration)
    }

    // Build the full timeline
    func timeline(for configuration: SelectStopIntent, in context: Context) async -> Timeline<ArrivalEntry> {
        let entry = await fetchEntry(for: configuration)

        // Create entries at 1-minute intervals so countdowns update
        var entries: [ArrivalEntry] = []
        let now = Date()
        for minuteOffset in 0..<15 {
            let entryDate = now.addingTimeInterval(Double(minuteOffset) * 60)
            entries.append(ArrivalEntry(
                date: entryDate,
                stop: entry.stop,
                arrivals: entry.arrivals,
                fetchedAt: entry.fetchedAt,
                isPlaceholder: false
            ))
        }

        // Refresh after 15 minutes
        let refreshDate = now.addingTimeInterval(15 * 60)
        return Timeline(entries: entries, policy: .after(refreshDate))
    }

    // Fetch arrivals for the configured stop
    private func fetchEntry(for configuration: SelectStopIntent) async -> ArrivalEntry {
        let now = Date()

        // If no stop configured, try the first saved stop as fallback
        let stop: TrackedStop?
        if let stopEntity = configuration.stop {
            stop = StopManager.shared.stops.first(where: { $0.id.uuidString == stopEntity.id })
        } else {
            stop = StopManager.shared.stops.first
        }

        guard let stop else {
            return ArrivalEntry(date: now, stop: nil, arrivals: [], fetchedAt: now, isPlaceholder: false)
        }

        do {
            let arrivals = try await MTAService.shared.fetchArrivals(
                route: stop.route,
                stopID: stop.platformStopID
            )
            let topArrivals = Array(arrivals.prefix(3))
            return ArrivalEntry(date: now, stop: stop, arrivals: topArrivals, fetchedAt: now, isPlaceholder: false)
        } catch {
            return ArrivalEntry(date: now, stop: stop, arrivals: [], fetchedAt: now, isPlaceholder: false)
        }
    }
}
