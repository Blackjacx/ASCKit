// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ASCKit",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v13),
       .watchOS(.v5),
       .tvOS(.v11),
    ],
    products: [
        .library(name: "ASCKit", targets: ["ASCKit"]),
    ],
    dependencies: [
        .package(name: "Engine", url: "https://github.com/blackjacx/engine", .branch("develop")),
//         .package(name: "Engine", path: "../Engine"),
        .package(name: "SwiftKeychainWrapper", url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(name: "Quick", url: "https://github.com/Quick/Quick", from: "3.1.2"),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.1.0"),
    ],
    targets: [
        .target(name: "ASCKit", dependencies: [.product(name: "JWTKit", package: "jwt-kit"), "Engine", "SwiftKeychainWrapper"]),
        .testTarget(name: "ASCKitTests", dependencies: ["ASCKit", "Quick", "Nimble"]),
    ]
)
