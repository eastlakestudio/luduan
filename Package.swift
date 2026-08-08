// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HornedFoxWords",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HornedFoxCore",
            targets: ["HornedFoxCore"]
        ),
        .executable(
            name: "HornedFoxApp",
            targets: ["HornedFoxApp"]
        )
    ],
    targets: [
        .target(
            name: "HornedFoxCore",
            path: "Sources/core",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "HornedFoxApp",
            dependencies: ["HornedFoxCore"],
            path: "Sources/app"
        ),
        .testTarget(
            name: "HornedFoxTests",
            dependencies: ["HornedFoxCore"],
            path: "Tests/HornedFoxTests"
        )
    ]
)
