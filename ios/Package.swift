// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "luDuan",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "luDuanCore",
            targets: ["luDuanCore"]
        ),
        .executable(
            name: "luDuan",
            targets: ["luDuan"]
        )
    ],
    targets: [
        .target(
            name: "luDuanCore",
            path: "Sources/core",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "luDuan",
            dependencies: ["luDuanCore"],
            path: "Sources/app"
        ),
        .testTarget(
            name: "luDuanTests",
            dependencies: ["luDuanCore"],
            path: "Tests/luDuanTests"
        )
    ]
)
