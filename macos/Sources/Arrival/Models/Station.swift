import Foundation

// Represents a subway station (parent) with its platform stops
struct Station: Identifiable, Hashable {
    let id: String          // Parent stop_id (e.g., "F25")
    let name: String        // Human-readable name (e.g., "15 St-Prospect Park")
    let latitude: Double
    let longitude: Double
    let northStopID: String? // Platform stop for northbound (e.g., "F25N")
    let southStopID: String? // Platform stop for southbound (e.g., "F25S")

    // The route prefix derived from the stop_id
    // e.g., "F25" -> "F", "101" -> "1", "A31" -> "A"
    var routePrefix: String {
        // Stop IDs like "101" -> route "1", "201" -> route "2"
        // Stop IDs like "A31" -> route "A", "F25" -> route "F"
        let id = self.id
        if let first = id.first {
            if first.isLetter {
                return String(first)
            } else {
                // Numeric prefix: first digit maps to route
                return String(first)
            }
        }
        return ""
    }

    // Infer the routes that likely serve this station based on the stop_id prefix
    var inferredRoutes: [String] {
        return StopIDRouteMapper.routes(forStopID: id)
    }
}

// Maps stop_id prefixes to the subway routes that serve them
// This is based on the GTFS stop_id conventions used by MTA
enum StopIDRouteMapper {
    static func routes(forStopID stopID: String) -> [String] {
        let prefix = stopID.prefix(1)
        switch prefix {
        case "1":
            return ["1", "2", "3"] // IRT Broadway-7th Ave
        case "2":
            return ["1", "2", "3"] // IRT Broadway-7th Ave (express)
        case "3":
            return ["4", "5", "6"] // IRT Lexington Ave
        case "4":
            return ["4", "5", "6"] // IRT Lexington Ave
        case "5":
            return ["4", "5", "6"] // IRT Pelham/Dyre
        case "6":
            return ["6"]           // IRT Pelham
        case "7":
            return ["7"]           // IRT Flushing
        case "9":
            return ["7"]           // 7 extension
        case "A":
            return ["A", "C"]      // IND 8th Ave
        case "B":
            return ["B", "D"]      // IND 6th Ave
        case "D":
            return ["B", "D", "F", "M"] // IND 6th Ave / Culver
        case "F":
            return ["F", "G"]      // IND Culver / Crosstown
        case "G":
            return ["G"]           // IND Crosstown
        case "H":
            return ["A", "S"]      // IND Rockaway
        case "J":
            return ["J", "Z"]      // BMT Nassau
        case "L":
            return ["L"]           // BMT Canarsie
        case "M":
            return ["M"]           // BMT Myrtle
        case "N":
            return ["N", "Q", "R", "W"] // BMT Broadway
        case "Q":
            return ["Q"]           // BMT Brighton
        case "R":
            return ["N", "R", "W"] // BMT 4th Ave
        case "S":
            return ["S"]           // Shuttles / SIR
        default:
            return []
        }
    }

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
