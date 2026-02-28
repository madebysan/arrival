import XCTest
@testable import Arrival

final class MTAServiceTests: XCTestCase {

    func testFeedURLForFTrain() {
        let url = StopIDRouteMapper.feedURL(for: "F")
        XCTAssertNotNil(url, "Should return a URL for the F train")
        XCTAssertTrue(url!.absoluteString.contains("bdfm"), "F train should use the BDFM feed")
    }

    func testFeedURLForAllRoutes() {
        let routes = ["1", "2", "3", "4", "5", "6", "7", "A", "C", "E",
                      "B", "D", "F", "M", "G", "J", "Z", "L", "N", "Q", "R", "W", "S"]
        for route in routes {
            let url = StopIDRouteMapper.feedURL(for: route)
            XCTAssertNotNil(url, "Should return a URL for route \(route)")
        }
    }

    func testFeedURLForInvalidRoute() {
        let url = StopIDRouteMapper.feedURL(for: "X")
        XCTAssertNil(url, "Should return nil for invalid route")
    }

    func testInferredRoutesForFStop() {
        let routes = StopIDRouteMapper.routes(forStopID: "F25")
        XCTAssertTrue(routes.contains("F"), "F25 should include F train")
    }

    func testInferredRoutesForNumberedStop() {
        let routes = StopIDRouteMapper.routes(forStopID: "101")
        XCTAssertTrue(routes.contains("1"), "101 should include 1 train")
    }

    func testArrivalCountdown() {
        let futureTime = Date().addingTimeInterval(300) // 5 minutes from now
        let arrival = Arrival(route: "F", destination: "Jamaica-179 St", arrivalTime: futureTime)
        let mins = arrival.currentMinutesAway
        // Allow +/- 1 minute tolerance
        XCTAssertTrue(mins >= 4 && mins <= 5, "Should be about 5 minutes away, got \(mins)")
        XCTAssertTrue(arrival.countdownText == "5 min" || arrival.countdownText == "4 min",
                      "Should show ~5 min, got \(arrival.countdownText)")
    }

    func testArrivalNow() {
        let now = Date().addingTimeInterval(20) // 20 seconds from now
        let arrival = Arrival(route: "F", destination: "Jamaica-179 St", arrivalTime: now)
        XCTAssertTrue(arrival.countdownText == "Now", "Should show Now, got \(arrival.countdownText)")
    }

    func testArrivalOnMinute() {
        let oneMin = Date().addingTimeInterval(90) // 1.5 minutes from now
        let arrival = Arrival(route: "F", destination: "Test", arrivalTime: oneMin)
        XCTAssertTrue(arrival.countdownText == "1 min", "Should show 1 min, got \(arrival.countdownText)")
    }
}
