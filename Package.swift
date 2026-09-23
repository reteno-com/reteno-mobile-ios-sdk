// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reteno",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Reteno", targets: ["Reteno"]),
        .library(name: "Reteno-Dynamic", type: .dynamic, targets: ["Reteno"])
    ],
    targets: [
        .target(
            name: "Reteno",
            path: "Reteno/Sources",
            resources: [.process("PrivacyInfo.xcprivacy")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
