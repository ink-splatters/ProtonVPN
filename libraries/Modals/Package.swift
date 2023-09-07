// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modals",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)],
    products: [
        .library(
            name: "Modals",
            targets: ["Modals"]),
        .library(
            name: "Modals-macOS",
            targets: ["Modals-macOS"]),
        .library(
            name: "Modals-iOS",
            targets: ["Modals-iOS"])
    ],
    dependencies: [
        .package(path: "../Strings"),
        .package(name: "Overture", url: "https://github.com/pointfreeco/swift-overture", .exact("0.5.0")),
        .package(path: "../Theme"),
        .package(path: "../Ergonomics"),
        .package(path: "../SharedViews")
    ],
    targets: [
        .target(
            name: "Modals",
            dependencies: [
                "Overture",
                "Strings",
                "Theme"
            ],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        ),
        .target(
            name: "Modals-iOS",
            dependencies: ["Modals", "Theme", "Ergonomics", "SharedViews"],
            resources: []
        ),
        .target(
            name: "Modals-macOS",
            dependencies: ["Modals", "Theme", "Ergonomics", "SharedViews"],
            resources: []
        ),
        .testTarget(
            name: "ModalsTests",
            dependencies: ["Modals", "Overture", "Theme"]
            )
    ]
)
