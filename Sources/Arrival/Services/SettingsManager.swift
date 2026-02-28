import Foundation
import Combine

// UserDefaults wrapper for app settings
class SettingsManager: ObservableObject {

    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let selectedStationID = "selectedStationID"
        static let selectedStationName = "selectedStationName"
        static let selectedRoute = "selectedRoute"
        static let selectedDirection = "selectedDirection" // "N" or "S"
        static let walkingTimeMinutes = "walkingTimeMinutes"
        static let hasCompletedSetup = "hasCompletedSetup"
    }

    // Default values
    private static let defaultStationID = "F25"
    private static let defaultStationName = "15 St-Prospect Park"
    private static let defaultRoute = "F"
    private static let defaultDirection = "N"
    private static let defaultWalkingTime = 5

    @Published var selectedStationID: String {
        didSet { defaults.set(selectedStationID, forKey: Keys.selectedStationID) }
    }

    @Published var selectedStationName: String {
        didSet { defaults.set(selectedStationName, forKey: Keys.selectedStationName) }
    }

    @Published var selectedRoute: String {
        didSet { defaults.set(selectedRoute, forKey: Keys.selectedRoute) }
    }

    @Published var selectedDirection: String {
        didSet { defaults.set(selectedDirection, forKey: Keys.selectedDirection) }
    }

    @Published var walkingTimeMinutes: Int {
        didSet { defaults.set(walkingTimeMinutes, forKey: Keys.walkingTimeMinutes) }
    }

    @Published var hasCompletedSetup: Bool {
        didSet { defaults.set(hasCompletedSetup, forKey: Keys.hasCompletedSetup) }
    }

    // The platform stop_id used for fetching arrivals (e.g., "F25N")
    var platformStopID: String {
        return selectedStationID + selectedDirection
    }

    // Human-readable direction label
    var directionLabel: String {
        switch selectedDirection {
        case "N":
            return "Uptown / Manhattan-bound"
        case "S":
            return "Downtown / Brooklyn-bound"
        default:
            return selectedDirection
        }
    }

    private init() {
        // Load saved values or use defaults
        self.selectedStationID = defaults.string(forKey: Keys.selectedStationID) ?? Self.defaultStationID
        self.selectedStationName = defaults.string(forKey: Keys.selectedStationName) ?? Self.defaultStationName
        self.selectedRoute = defaults.string(forKey: Keys.selectedRoute) ?? Self.defaultRoute
        self.selectedDirection = defaults.string(forKey: Keys.selectedDirection) ?? Self.defaultDirection
        self.walkingTimeMinutes = defaults.object(forKey: Keys.walkingTimeMinutes) as? Int ?? Self.defaultWalkingTime
        self.hasCompletedSetup = defaults.bool(forKey: Keys.hasCompletedSetup)
    }

    // Update all station settings at once
    func selectStation(id: String, name: String, route: String, direction: String) {
        self.selectedStationID = id
        self.selectedStationName = name
        self.selectedRoute = route
        self.selectedDirection = direction
        self.hasCompletedSetup = true
    }
}
