// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "ASCKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "ASCKit", targets: ["ASCKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/blackjacx/Engine", from: "0.3.0"),
//        .package(path: "../Engine"),
    ],
    targets: [
        .target(
            name: "ASCKit",
            dependencies: [
                "Engine",
            ]
        ),
        .testTarget(
            name: "ASCKitTests",
            dependencies: [
                "ASCKit",
            ]
        ),
    ],
)
