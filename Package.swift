// swift-tools-version: 6.0.0
import PackageDescription

let package = Package(
    name: "HomeyMusicKit",
    platforms: [
        .iOS(.v17), .macOS(.v15)
    ],
    products: [
        .library(
            name: "HomeyMusicKit",
            targets: ["HomeyMusicKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.10.1"),
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.2"),
        .package(url: "https://github.com/dunne/DunneAudioKit.git", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "HomeyMusicKit",
            dependencies: [
                // Link MIDIKit to the HomeyMusicKit target
                .product(name: "MIDIKit", package: "MIDIKit"),
                .product(name: "MIDIKitCore", package: "MIDIKit"),
                .product(name: "MIDIKitIO", package: "MIDIKit"),
                .product(name: "AudioKit", package: "AudioKit"),
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
