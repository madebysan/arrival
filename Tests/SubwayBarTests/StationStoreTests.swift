import XCTest
@testable import SubwayBar

final class StationStoreTests: XCTestCase {

    func testStationsLoaded() {
        let store = StationStore.shared
        // stops.txt has ~496 parent stations
        XCTAssertGreaterThan(store.stations.count, 100, "Should load at least 100 stations from stops.txt")
    }

    func testSearchByName() {
        let store = StationStore.shared
        let results = store.search(query: "prospect")
        XCTAssertFalse(results.isEmpty, "Should find stations matching 'prospect'")
        XCTAssertTrue(
            results.contains { $0.name.lowercased().contains("prospect") },
            "All results should contain 'prospect'"
        )
    }

    func testSearchEmpty() {
        let store = StationStore.shared
        let results = store.search(query: "")
        XCTAssertTrue(results.count == store.stations.count, "Empty search should return all stations")
    }

    func testSearchNoResults() {
        let store = StationStore.shared
        let results = store.search(query: "zzzznonexistent")
        XCTAssertTrue(results.isEmpty, "Nonsense query should return no results")
    }

    func testStationByID() {
        let store = StationStore.shared
        let station = store.station(byID: "F25")
        XCTAssertNotNil(station, "Should find station F25 (15 St-Prospect Park)")
        if let station = station {
            XCTAssertTrue(station.name == "15 St-Prospect Park",
                          "Station name should be '15 St-Prospect Park', got '\(station.name)'")
        }
    }

    func testStationHasPlatformStops() {
        let store = StationStore.shared
        if let station = store.station(byID: "F25") {
            XCTAssertNotNil(station.northStopID, "Station should have a north platform stop")
            XCTAssertNotNil(station.southStopID, "Station should have a south platform stop")
            XCTAssertTrue(station.northStopID == "F25N", "North stop should be F25N")
            XCTAssertTrue(station.southStopID == "F25S", "South stop should be F25S")
        } else {
            XCTFail("Could not find station F25")
        }
    }
}
