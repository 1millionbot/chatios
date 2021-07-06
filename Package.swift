// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OneMillionBot",
    defaultLocalization: "es",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "OneMillionBot",
            targets: ["OneMillionBot"]
        )
    ],
    dependencies: [
        .package(name: "Atributika", url: "https://github.com/psharanda/Atributika", .upToNextMajor(from: "4.10.1")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.2")),
        .package(url: "https://github.com/JanGorman/Agrume", .upToNextMajor(from: "5.6.12")),
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", .upToNextMinor(from: "0.1.2")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "6.0.1")),
        .package(name: "SocketIO", url: "https://github.com/socketio/socket.io-client-swift", .upToNextMajor(from: "16.0.1"))
    ],
    targets: [
        .target(
            name: "OneMillionBot",
            dependencies: [
                "Agrume", "KeychainAccess", "Kingfisher", "Atributika",
                .product(name: "SocketIO", package: "SocketIO"),
                .product(name: "Introspect", package: "Introspect")
            ],
            path: "Sources",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
