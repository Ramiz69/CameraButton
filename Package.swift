// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CameraButton",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "CameraButton",
            targets: ["CameraButton"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CameraButton",
            dependencies: [])
    ],
    swiftLanguageModes: [.v6]
)
