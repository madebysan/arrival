// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Arrival",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),
    ],
    targets: [
        .executableTarget(
            name: "Arrival",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/stops.txt"),
            ]
        ),
        .testTarget(
            name: "ArrivalTests",
            dependencies: ["Arrival"]
        ),
    ]
)
