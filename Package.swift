// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SubwayBar",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),
    ],
    targets: [
        .executableTarget(
            name: "SubwayBar",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/stops.txt"),
            ]
        ),
        .testTarget(
            name: "SubwayBarTests",
            dependencies: ["SubwayBar"]
        ),
    ]
)
