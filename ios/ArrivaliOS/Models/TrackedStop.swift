import Foundation

// A saved stop the user wants to track (e.g., "F at 15th St uptown")
struct TrackedStop: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let route: String               // e.g., "F"
    let stationID: String           // Parent station ID, e.g., "F25"
    let stationName: String         // e.g., "15 St-Prospect Park"
    let direction: String           // "N" or "S"
    var walkingTimeMinutes: Int     // Minutes to walk to the station

    // The platform stop_id used for fetching arrivals (e.g., "F25N")
    var platformStopID: String {
        stationID + direction
    }

    // Human-readable direction label
    var directionLabel: String {
        switch direction {
        case "N": return "Uptown"
        case "S": return "Downtown"
        default: return direction
        }
    }

    // Short summary for display
    var summary: String {
        "\(route) at \(stationName) (\(directionLabel))"
    }
}
