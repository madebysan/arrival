#!/usr/bin/swift

// Generates a programmatic app icon for Arrival
// Orange circle with white "F" — subway bullet style

import Cocoa

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

// Also generate a 256px PNG for README
let readmeSizes: [(Int, String)] = [
    (256, "app-icon.png"),
]

func drawIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    // Orange background circle
    let orange = NSColor(red: 1.0, green: 0.384, blue: 0.0, alpha: 1.0) // MTA orange
    orange.setFill()
    let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: CGFloat(size) * 0.02, dy: CGFloat(size) * 0.02))
    circlePath.fill()

    // Subtle shadow/depth
    let darkOrange = NSColor(red: 0.85, green: 0.3, blue: 0.0, alpha: 0.3)
    darkOrange.setFill()
    let shadowRect = NSRect(
        x: 0,
        y: 0,
        width: size,
        height: Int(Double(size) * 0.48)
    )
    let shadowPath = NSBezierPath(ovalIn: rect.insetBy(dx: CGFloat(size) * 0.02, dy: CGFloat(size) * 0.02))
    shadowPath.setClip()
    NSBezierPath(rect: shadowRect).fill()

    // Reset clip
    NSBezierPath(rect: rect).setClip()

    // White "F" letter
    let fontSize = CGFloat(size) * 0.58
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
    ]
    let text = "F"
    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (CGFloat(size) - textSize.width) / 2,
        y: (CGFloat(size) - textSize.height) / 2 - CGFloat(size) * 0.01,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(path)")
        return
    }
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Created: \(path)")
    } catch {
        print("Error writing \(path): \(error)")
    }
}

// Get script directory
let scriptPath = CommandLine.arguments[0]
let projectDir = URL(fileURLWithPath: scriptPath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .path

// Create iconset directory
let iconsetDir = "\(projectDir)/dist/Arrival.iconset"
let assetsDir = "\(projectDir)/assets"

let fm = FileManager.default
try? fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)
try? fm.createDirectory(atPath: assetsDir, withIntermediateDirectories: true)

// Generate iconset PNGs
for (size, name) in sizes {
    let image = drawIcon(size: size)
    savePNG(image, to: "\(iconsetDir)/\(name)")
}

// Generate README icon
for (size, name) in readmeSizes {
    let image = drawIcon(size: size)
    savePNG(image, to: "\(assetsDir)/\(name)")
}

print("Icon generation complete!")
print("Run: iconutil -c icns \(iconsetDir)")
