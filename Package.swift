// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StretchReminder",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "StretchReminder",
            targets: ["StretchReminder"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "StretchReminder",
            dependencies: []
        )
    ]
)
