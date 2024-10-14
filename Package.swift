// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeyMusicKit",
    platforms: [
        .iOS(.v13), .macOS(.v11)
    ],
    products: [
        .library(
            name: "HomeyMusicKit",
            targets: ["HomeyMusicKit"]
        ),
    ],
    targets: [
        .target(
            name: "HomeyMusicKit",
            resources: [
                .process("Assets.xcassets")  // Include the assets catalog
            ]
        ),
        .testTarget(
            name: "HomeyMusicKitTests",
            dependencies: ["HomeyMusicKit"]
        ),
    ]
)
