// swift-tools-version:5.5.0

import PackageDescription

let package = Package(
    name: "OG",
    platforms: [
		.macOS(.v10_10), .iOS(.v10), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "OG", targets: ["OG"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OG",
            dependencies: [],
            path: "Sources",
            exclude: ["Info.plist"]
        ),
         .testTarget(
            name: "Tests",
            dependencies: ["OG"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
