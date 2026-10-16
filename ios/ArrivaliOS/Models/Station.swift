import Foundation

// Represents a subway station (parent) with its platform stops
struct Station: Identifiable, Hashable {
    let id: String          // Parent stop_id (e.g., "F25")
    let name: String        // Human-readable name (e.g., "15 St-Prospect Park")
    let latitude: Double
    let longitude: Double
    let northStopID: String? // Platform stop for northbound (e.g., "F25N")
    let southStopID: String? // Platform stop for southbound (e.g., "F25S")
}

// Maps each subway route to its MTA realtime feed
enum StopIDRouteMapper {
    // Get the feed URL for a given route
    static func feedURL(for route: String) -> URL? {
        let baseURL = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2F"
        let feedPath: String
        switch route.uppercased() {
        case "1", "2", "3", "4", "5", "6", "7", "S":
            feedPath = "gtfs"
        case "A", "C", "E":
            feedPath = "gtfs-ace"
        case "B", "D", "F", "M":
            feedPath = "gtfs-bdfm"
        case "G":
            feedPath = "gtfs-g"
        case "J", "Z":
            feedPath = "gtfs-jz"
        case "N", "Q", "R", "W":
            feedPath = "gtfs-nqrw"
        case "L":
            feedPath = "gtfs-l"
        case "SI", "SIR":
            feedPath = "gtfs-si"
        default:
            return nil
        }
        return URL(string: baseURL + feedPath)
    }
}
