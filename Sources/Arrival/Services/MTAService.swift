import Foundation
import SwiftProtobuf

// Fetches and parses MTA GTFS-Realtime feeds
class MTAService {

    static let shared = MTAService()

    private let session: URLSession
    private let alertsURL = URL(string: "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/camsys%2Fall-alerts")!

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Fetch Arrivals

    // Fetch upcoming arrivals for a specific stop and route
    func fetchArrivals(
        route: String,
        stopID: String
    ) async throws -> [Arrival] {
        guard let feedURL = StopIDRouteMapper.feedURL(for: route) else {
            throw MTAError.invalidRoute(route)
        }

        let data = try await fetchData(from: feedURL)
        let feed = try TransitRealtime_FeedMessage(serializedBytes: Array(data))

        var arrivals: [Arrival] = []
        let now = Date()

        for entity in feed.entity {
            guard entity.hasTripUpdate else { continue }
            let tripUpdate = entity.tripUpdate

            // Get the route for this trip
            let tripRoute = tripUpdate.trip.routeID
            // We want arrivals for any route at our stop, not just the selected one
            // This way if an F and G both stop here, we see both

            for stopTimeUpdate in tripUpdate.stopTimeUpdate {
                // Check if this is our stop
                guard stopTimeUpdate.stopID == stopID else { continue }

                // Get arrival time (prefer arrival, fall back to departure)
                let timestamp: Int64
                if stopTimeUpdate.hasArrival && stopTimeUpdate.arrival.time > 0 {
                    timestamp = stopTimeUpdate.arrival.time
                } else if stopTimeUpdate.hasDeparture && stopTimeUpdate.departure.time > 0 {
                    timestamp = stopTimeUpdate.departure.time
                } else {
                    continue
                }

                let arrivalDate = Date(timeIntervalSince1970: TimeInterval(timestamp))

                // Skip trains that have already passed
                guard arrivalDate > now else { continue }

                // Try to get a destination from the last stop in the trip
                let destination = destinationForTrip(tripUpdate)

                let arrival = Arrival(
                    route: tripRoute,
                    destination: destination,
                    arrivalTimestamp: timestamp
                )
                arrivals.append(arrival)
            }
        }

        // Sort by arrival time and return the closest ones
        arrivals.sort { $0.arrivalTime < $1.arrivalTime }
        return arrivals
    }

    // Try to determine the destination from the trip's last stop
    private func destinationForTrip(_ tripUpdate: TransitRealtime_TripUpdate) -> String {
        // The trip_id often encodes the destination
        // Format is usually like: "064350_F..N" where N = northbound
        let tripID = tripUpdate.trip.tripID

        // Try to get the last stop in the stop time updates
        if let lastStop = tripUpdate.stopTimeUpdate.last {
            let lastStopID = lastStop.stopID
            // Look up station name from the store
            let parentID = String(lastStopID.dropLast()) // Remove N/S suffix
            if let station = StationStore.shared.station(byID: parentID) {
                return station.name
            }
        }

        // Fall back to direction from trip_id
        if tripID.contains("..N") || tripID.contains("..1") {
            return "Uptown"
        } else if tripID.contains("..S") || tripID.contains("..3") {
            return "Downtown"
        }

        return ""
    }

    // MARK: - Fetch Service Alerts

    // Fetch service alerts for a specific route
    func fetchAlerts(for route: String) async throws -> [ServiceAlert] {
        let data = try await fetchData(from: alertsURL)
        let feed = try TransitRealtime_FeedMessage(serializedBytes: Array(data))

        var alerts: [ServiceAlert] = []

        for entity in feed.entity {
            guard entity.hasAlert else { continue }
            let alert = entity.alert

            // Check if this alert affects our route
            let affectedRoutes = alert.informedEntity.compactMap { informed -> String? in
                if informed.hasRouteID {
                    return informed.routeID
                }
                return nil
            }

            // Only include alerts for the subway (check agency or route match)
            let isRelevant = affectedRoutes.contains { $0.uppercased() == route.uppercased() }
            guard isRelevant else { continue }

            // Extract header text
            let headerText: String
            if alert.hasHeaderText {
                headerText = alert.headerText.translation.first?.text ?? "Service alert"
            } else {
                headerText = "Service alert"
            }

            // Extract description text
            let descriptionText: String
            if alert.hasDescriptionText {
                descriptionText = alert.descriptionText.translation.first?.text ?? ""
            } else {
                descriptionText = ""
            }

            // Active period
            let activePeriod = alert.activePeriod.first
            let start = activePeriod.map { Date(timeIntervalSince1970: TimeInterval($0.start)) }
            let end = activePeriod.map { ap -> Date? in
                ap.end > 0 ? Date(timeIntervalSince1970: TimeInterval(ap.end)) : nil
            } ?? nil

            let serviceAlert = ServiceAlert(
                id: entity.id,
                headerText: headerText,
                descriptionText: descriptionText,
                affectedRoutes: affectedRoutes,
                activePeriodStart: start,
                activePeriodEnd: end
            )

            if serviceAlert.isActive {
                alerts.append(serviceAlert)
            }
        }

        return alerts
    }

    // MARK: - Network

    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MTAError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MTAError.httpError(httpResponse.statusCode)
        }

        return data
    }
}

// MTA service errors
enum MTAError: LocalizedError {
    case invalidRoute(String)
    case invalidResponse
    case httpError(Int)
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidRoute(let route):
            return "Unknown route: \(route)"
        case .invalidResponse:
            return "Invalid response from MTA"
        case .httpError(let code):
            return "MTA returned HTTP \(code)"
        case .decodingError(let detail):
            return "Failed to decode feed: \(detail)"
        }
    }
}
