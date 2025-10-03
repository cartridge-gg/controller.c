// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ControllerSDK",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ControllerSDK",
            targets: ["ControllerSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CControllerBridge",
            dependencies: [],
            path: "Sources/CControllerBridge",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedLibrary("controller_c"),
                .unsafeFlags(["-L../../../target/release"])
            ]
        ),
        .target(
            name: "ControllerSDK",
            dependencies: ["CControllerBridge"],
            path: "Sources/ControllerSDK"
        ),
        .testTarget(
            name: "ControllerSDKTests",
            dependencies: ["ControllerSDK"]
        ),
    ]
)