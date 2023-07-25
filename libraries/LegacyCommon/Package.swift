// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LegacyCommon",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LegacyCommon",
            targets: ["LegacyCommon"]
        ),
        .library(
            name: "LegacyCommonTestSupport",
            targets: ["LegacyCommonTestSupport"]
        ),
    ],
    dependencies: [
        // External packages regularly upstreamed by our project (imported as submodules)
        .package(path: "../../external/protoncore"),
        .package(path: "../../external/tunnelkit"),
        .package(path: "../../external/trustkit"),

        // Local packages
        .package(path: "../BugReport"),
        .package(path: "../ConnectionDetails"),
        .package(path: "../Modals"),
        .package(path: "../Home"),
        .package(path: "../LocalFeatureFlags"),
        .package(path: "../NEHelper"),
        .package(path: "../PMLogger"),
        .package(path: "../SharedViews"),
        .package(path: "../Settings"),
        .package(path: "../Strings"),
        .package(path: "../Theme"),
        .package(path: "../Timer"),

        // External dependencies
        .github("apple", repo: "swift-collections", .upToNextMajor(from: "1.0.4")),
        .github("ashleymills", repo: "Reachability.swift", exact: "5.1.0"),
        .github("getsentry", repo: "sentry-cocoa", exact: "8.9.0"),
        .github("kishikawakatsumi", repo: "KeychainAccess", exact: "3.2.1"),
        .github("pointfreeco", repo: "swift-clocks", .upToNextMajor(from: "0.3.0")),
        .github("pointfreeco", repo: "swift-composable-architecture", exact: "0.55.0"),
        .github("pointfreeco", repo: "swift-dependencies", .upToNextMajor(from: "0.1.1")),
        .github("pointfreeco", repo: "swiftui-navigation", exact: "0.8.0"),
        .github("SDWebImage", repo: "SDWebImage", .upTo("5.16.0")),
    ],
    targets: [
        .target(
            name: "LegacyCommon",
            dependencies: [
                // Local
                "Strings",
                "Theme",
                "BugReport",
                .product(name: "VPNShared", package: "NEHelper"),
                .product(name: "VPNAppCore", package: "NEHelper"),

                // Core code
                .core(module: "AccountDeletion"),
                .core(module: "APIClient"),
                .core(module: "Authentication"),
                .core(module: "Challenge"),
                .core(module: "DataModel"),
                .core(module: "Doh"),
                .core(module: "Environment"),
                .core(module: "FeatureSwitch"),
                .core(module: "ForceUpgrade"),
                .core(module: "Foundations"),
                .product(name: "GoLibsCryptoVPNPatchedGo", package: "protoncore"),
                .core(module: "HumanVerification"),
                .core(module: "Log"),
                .core(module: "Login"),
                .core(module: "Networking"),
                .core(module: "Payments"),
                .core(module: "Services"),
                .core(module: "UIFoundations"),
                .core(module: "Utilities"),

                // External
                .product(name: "Clocks", package: "swift-clocks"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "TrustKit", package: "TrustKit"),
                .product(name: "TunnelKit", package: "TunnelKit"),
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
            ]
        ),
        .target(
            name: "LegacyCommonTestSupport",
            dependencies: [
                "LegacyCommon",
                .product(name: "VPNSharedTesting", package: "NEHelper"),
                .product(name: "GoLibsCryptoVPNPatchedGo", package: "protoncore"),
            ]
        ),
        .testTarget(
            name: "LegacyCommonTests",
            dependencies: [
                "LegacyCommon",
                .target(name: "LegacyCommonTestSupport"),
                .product(name: "TimerMock", package: "Timer"),
                .product(name: "VPNShared", package: "NEHelper"),
                .product(name: "VPNAppCore", package: "NEHelper"),
                .core(module: "TestingToolkitUnitTestsCore")
            ]
        ),
    ]
)

extension Range<PackageDescription.Version> {
    static func upTo(_ version: Version) -> Self {
        "0.0.0"..<version
    }
}

extension PackageDescription.Package.Dependency {
    static func github(_ author: String, repo: String, exact version: Version) -> Package.Dependency {
        .package(url: "https://github.com/\(author)/\(repo)", exact: version)
    }

    static func github(_ author: String, repo: String, _ range: Range<Version>) -> Package.Dependency {
        .package(url: "https://github.com/\(author)/\(repo)", range)
    }
}

extension PackageDescription.Target.Dependency {
    static func core(module: String) -> Self {
        .product(name: "ProtonCore\(module)", package: "protoncore")
    }
}
