// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aux",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuxCore",
            targets: ["AuxCore"]
        ),
        .library(
            name: "AuxUI",
            targets: ["AuxUI"]
        )
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "AuxCore",
            dependencies: [],
            path: "Sources/AuxCore"
        ),
        .target(
            name: "AuxUI",
            dependencies: ["AuxCore"],
            path: "Sources/AuxUI"
        ),
        .testTarget(
            name: "AuxCoreTests",
            dependencies: ["AuxCore"],
            path: "Tests/AuxCoreTests"
        ),
        .testTarget(
            name: "AuxUITests", 
            dependencies: ["AuxUI"],
            path: "Tests/AuxUITests"
        )
    ]
)