// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ASCKit",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
//        .iOS(.v15),
//        .tvOS(.v15),
//        .watchOS(.v8)
    ],
    products: [
        .library(name: "ASCKit", targets: ["ASCKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/blackjacx/Engine", from: "0.0.3"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(url: "https://github.com/Quick/Quick", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.1.0"),
    ],
    targets: [
        .target(name: "ASCKit", dependencies: [.product(name: "JWTKit", package: "jwt-kit"), "Engine", "SwiftKeychainWrapper"]),
        .testTarget(name: "ASCKitTests", dependencies: ["ASCKit", "Quick", "Nimble"]),
    ]
)
