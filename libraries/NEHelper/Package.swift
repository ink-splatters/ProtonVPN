// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NEHelper",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(name: "NEHelper", targets: ["NEHelper"]),
        .library(name: "VPNAppCore", targets: ["VPNAppCore"]),
        .library(name: "VPNShared", targets: ["VPNShared"]),
        .library(name: "VPNSharedTesting", targets: ["VPNSharedTesting"]),
    ],
    dependencies: [
        .package(path: "../Ergonomics"),
        .package(path: "../Timer"),
        .package(path: "../PMLogger"),
        .package(path: "../LocalFeatureFlags"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.4.4"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "3.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "0.5.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "0.8.5"),
    ],
    targets: [
        .target(
            name: "VPNShared",
            dependencies: [
                .product(name: "Ergonomics", package: "Ergonomics"),
                .product(name: "Timer", package: "Timer"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "PMLogger", package: "PMLogger"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "LocalFeatureFlags", package: "LocalFeatureFlags"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "NEHelper",
            dependencies: [
                .product(name: "Timer", package: "Timer"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "LocalFeatureFlags", package: "LocalFeatureFlags"),
                "VPNShared",
            ]
        ),
        .target(
            name: "VPNAppCore",
            dependencies: [
                "VPNShared",
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "VPNSharedTesting",
            dependencies: ["VPNShared", .product(name: "TimerMock", package: "Timer")]
        ),
        .testTarget(name: "VPNSharedTests", dependencies: ["VPNShared"]),
        .testTarget(name: "NEHelperTests", dependencies: ["NEHelper", "VPNSharedTesting"]),
    ]
)
