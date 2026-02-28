import Foundation

// Represents a single upcoming train arrival
struct Arrival: Identifiable {
    let id = UUID()
    let route: String           // e.g., "F"
    let destination: String     // e.g., "Jamaica-179 St" or direction label
    let arrivalTime: Date       // When the train arrives
    let minutesAway: Int        // Computed minutes until arrival

    // Create from a Unix timestamp
    init(route: String, destination: String, arrivalTimestamp: Int64) {
        self.route = route
        self.destination = destination
        self.arrivalTime = Date(timeIntervalSince1970: TimeInterval(arrivalTimestamp))
        let seconds = max(0, Int(self.arrivalTime.timeIntervalSinceNow))
        self.minutesAway = seconds / 60
    }

    // Create from a Date
    init(route: String, destination: String, arrivalTime: Date) {
        self.route = route
        self.destination = destination
        self.arrivalTime = arrivalTime
        let seconds = max(0, Int(arrivalTime.timeIntervalSinceNow))
        self.minutesAway = seconds / 60
    }

    // Recalculate minutes (for display refresh)
    var currentMinutesAway: Int {
        let seconds = max(0, Int(arrivalTime.timeIntervalSinceNow))
        return seconds / 60
    }

    // Display string for the countdown
    var countdownText: String {
        let mins = currentMinutesAway
        if mins == 0 {
            return "Now"
        } else if mins == 1 {
            return "1 min"
        } else {
            return "\(mins) min"
        }
    }
}
