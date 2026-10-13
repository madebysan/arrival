// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Arrival",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "Arrival",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/stops.txt"),
            ],
            // Sparkle.framework is embedded in Contents/Frameworks by scripts/build-dmg.sh.
            linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]
        ),
        .testTarget(
            name: "ArrivalTests",
            dependencies: ["Arrival"]
        ),
    ]
)
