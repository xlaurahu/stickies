// swift-tools-version: 6.2.4

import PackageDescription

let package = Package(
    name: "StickyNotes",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/metasidd/ColorTokensKit-Swift.git", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "StickyNotes",
            dependencies: [
                .product(name: "ColorTokensKit", package: "ColorTokensKit-Swift")
            ],
            path: "Sources"
        )
    ]
)
