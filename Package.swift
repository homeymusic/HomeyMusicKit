// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "HomeyMusicKit",
    platforms: [
        .iOS(.v13), .macOS(.v12)
    ],
    products: [
        .library(
            name: "HomeyMusicKit",
            targets: ["HomeyMusicKit"]
        ),
    ],
    dependencies: [
        // Adding MIDIKit as a dependency
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.6.1"),
        // Adding AudioKit as a dependency
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.3.0"),
        // Adding DunneAudioKit as a dependency
        .package(url: "https://github.com/AudioKit/DunneAudioKit.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "HomeyMusicKit",
            dependencies: [
                // Link MIDIKit to the HomeyMusicKit target
                .product(name: "MIDIKit", package: "MIDIKit"),
                .product(name: "MIDIKitCore", package: "MIDIKit"),
                .product(name: "MIDIKitIO", package: "MIDIKit"),
                // Link AudioKit to the HomeyMusicKit target
                .product(name: "AudioKit", package: "AudioKit"),
                // Link DunneAudioKit to the HomeyMusicKit target
                .product(name: "DunneAudioKit", package: "DunneAudioKit")
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
