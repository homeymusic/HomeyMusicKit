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
    dependencies: [
        // Add MIDIKit as a dependency
        .package(
            url: "https://github.com/orchetect/MIDIKit",
            from: "0.4.2"  // Specify the version of MIDIKit you want
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
