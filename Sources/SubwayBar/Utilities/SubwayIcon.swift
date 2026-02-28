import AppKit
import SwiftUI

// Generates colored subway bullet icons for the menu bar and UI
enum SubwayIcon {

    // Create a colored subway bullet NSImage for the menu bar
    // The icon is a filled circle with the route letter/number in white
    static func menuBarIcon(route: String, size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        // Draw colored circle
        let bgColor = SubwayColors.nsColor(for: route)
        bgColor.setFill()
        let circlePath = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: size, height: size))
        circlePath.fill()

        // Draw route letter
        let textColor: NSColor
        switch route.uppercased() {
        case "N", "Q", "R", "W":
            textColor = .black
        default:
            textColor = .white
        }

        let fontSize = size * 0.6
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
        ]

        let text = route.uppercased()
        let textSize = text.size(withAttributes: attributes)
        let textX = (size - textSize.width) / 2
        let textY = (size - textSize.height) / 2
        text.draw(at: NSPoint(x: textX, y: textY), withAttributes: attributes)

        image.unlockFocus()
        image.isTemplate = false // Keep the color, don't let macOS template it
        return image
    }

    // SwiftUI view for a subway bullet
    struct BulletView: View {
        let route: String
        var size: CGFloat = 22

        var body: some View {
            ZStack {
                Circle()
                    .fill(SubwayColors.color(for: route))
                    .frame(width: size, height: size)
                Text(route.uppercased())
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(SubwayColors.textColor(for: route))
            }
        }
    }
}
