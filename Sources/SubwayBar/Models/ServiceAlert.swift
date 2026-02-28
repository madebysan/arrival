import Foundation

// Represents a service alert for a subway route
struct ServiceAlert: Identifiable {
    let id: String
    let headerText: String
    let descriptionText: String
    let affectedRoutes: [String]
    let activePeriodStart: Date?
    let activePeriodEnd: Date?

    // Whether this alert is currently active
    var isActive: Bool {
        let now = Date()
        if let start = activePeriodStart, now < start {
            return false
        }
        if let end = activePeriodEnd, now > end {
            return false
        }
        return true
    }
}
