// swift-tools-version: 5.5
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
    dependencies: [
        // Adding MIDIKit as a dependency
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.6.1")
    ],
    targets: [
        .target(
            name: "HomeyMusicKit",
            dependencies: [
                // Link MIDIKit to the HomeyMusicKit target
                .product(name: "MIDIKitCore", package: "MIDIKit")
            ],
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
