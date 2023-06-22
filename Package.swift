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
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.2"),
        .package(name: "Sentry", url: "https://github.com/getsentry/sentry-cocoa", from: "8.8.0")
    ],
    targets: [
        .target(
            name: "Reteno",
            dependencies: ["Alamofire", "Sentry"],
            path: "Reteno/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
