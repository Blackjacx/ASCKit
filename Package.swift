// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ASCKit",
//    platforms: [.macOS(.v10_15), .macCatalyst(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    platforms: [
        .macOS("12"),
//        .iOS("15"),
//        .tvOS("15"),
//        .watchOS("8")
    ],
    products: [
        .library(name: "ASCKit", targets: ["ASCKit"]),
    ],
    dependencies: [
        .package(name: "Engine", url: "https://github.com/blackjacx/engine", from: "0.0.3"),
        .package(name: "SwiftKeychainWrapper", url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(name: "Quick", url: "https://github.com/Quick/Quick", from: "4.0.0"),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.1.0"),
    ],
    targets: [
        .target(name: "ASCKit", dependencies: [.product(name: "JWTKit", package: "jwt-kit"), "Engine", "SwiftKeychainWrapper"]),
        .testTarget(name: "ASCKitTests", dependencies: ["ASCKit", "Quick", "Nimble"]),
    ]
)
