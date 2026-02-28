import SwiftUI

// Official MTA subway line colors
// Reference: https://new.mta.info/document/36551
enum SubwayColors {
    // Returns the official MTA color for a given route
    static func color(for route: String) -> Color {
        switch route.uppercased() {
        // IRT lines
        case "1", "2", "3":
            return Color(red: 0.933, green: 0.235, blue: 0.235) // #EE3C3C — Red
        case "4", "5", "6":
            return Color(red: 0.0, green: 0.576, blue: 0.235)   // #00933C — Green
        case "7":
            return Color(red: 0.714, green: 0.224, blue: 0.718)  // #B633AD — Purple
        // IND lines
        case "A", "C", "E":
            return Color(red: 0.0, green: 0.341, blue: 0.722)    // #0039A6 — Blue
        case "B", "D", "F", "M":
            return Color(red: 1.0, green: 0.384, blue: 0.0)      // #FF6319 — Orange
        case "G":
            return Color(red: 0.420, green: 0.749, blue: 0.255)  // #6CBE45 — Light green
        // BMT lines
        case "J", "Z":
            return Color(red: 0.588, green: 0.471, blue: 0.282)  // #996633 — Brown
        case "L":
            return Color(red: 0.627, green: 0.627, blue: 0.627)  // #A7A9AC — Gray
        case "N", "Q", "R", "W":
            return Color(red: 0.988, green: 0.800, blue: 0.0)    // #FCCC0A — Yellow
        // Shuttles
        case "S", "GS", "FS", "H":
            return Color(red: 0.502, green: 0.502, blue: 0.502)  // #808183 — Dark gray
        // SIR
        case "SI", "SIR":
            return Color(red: 0.0, green: 0.341, blue: 0.722)    // #0039A6 — Blue
        default:
            return Color.gray
        }
    }

    // Text color for readability on the bullet background
    static func textColor(for route: String) -> Color {
        switch route.uppercased() {
        case "N", "Q", "R", "W":
            return .black // Yellow background needs dark text
        default:
            return .white
        }
    }

    // NSColor version for menu bar icon rendering
    static func nsColor(for route: String) -> NSColor {
        switch route.uppercased() {
        case "1", "2", "3":
            return NSColor(red: 0.933, green: 0.235, blue: 0.235, alpha: 1)
        case "4", "5", "6":
            return NSColor(red: 0.0, green: 0.576, blue: 0.235, alpha: 1)
        case "7":
            return NSColor(red: 0.714, green: 0.224, blue: 0.718, alpha: 1)
        case "A", "C", "E":
            return NSColor(red: 0.0, green: 0.341, blue: 0.722, alpha: 1)
        case "B", "D", "F", "M":
            return NSColor(red: 1.0, green: 0.384, blue: 0.0, alpha: 1)
        case "G":
            return NSColor(red: 0.420, green: 0.749, blue: 0.255, alpha: 1)
        case "J", "Z":
            return NSColor(red: 0.588, green: 0.471, blue: 0.282, alpha: 1)
        case "L":
            return NSColor(red: 0.627, green: 0.627, blue: 0.627, alpha: 1)
        case "N", "Q", "R", "W":
            return NSColor(red: 0.988, green: 0.800, blue: 0.0, alpha: 1)
        case "S", "GS", "FS", "H":
            return NSColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1)
        case "SI", "SIR":
            return NSColor(red: 0.0, green: 0.341, blue: 0.722, alpha: 1)
        default:
            return NSColor.gray
        }
    }
}
