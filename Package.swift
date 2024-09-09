// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reteno",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Reteno", targets: ["Reteno"]),
        .library(name: "Reteno-Dynamic", type: .dynamic, targets: ["Reteno"])
    ],
    targets: [
        .target(
            name: "Reteno",
            path: "Reteno/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
