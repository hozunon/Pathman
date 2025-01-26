// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pathman",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "Pathman", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "TOMLKit", package: "TOMLKit"),
        ]),
    ]
)
