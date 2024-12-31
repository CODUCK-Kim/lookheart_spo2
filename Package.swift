// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LookheartPackage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LookheartPackage",
            targets: ["LookheartPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/devxoul/Then", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/scalessec/Toast-Swift", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.4"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.0"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "24.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "7.1.0")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.0.0")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .exact("4.0.4"))
    ],
    
    targets: [
        .target(
            name: "LookheartPackage",
            dependencies: [
                .product(name: "DGCharts", package: "Charts"),
                "Alamofire",
                "SnapKit",
                "Then",
                .product(name: "Toast", package: "Toast-Swift"),
                "FSCalendar",
                "PhoneNumberKit",
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Swinject",
                .product(name: "SocketIO", package: "socket.io-client-swift"),
                .product(name: "Starscream", package: "Starscream")
            ],
            resources: [
                .process("Alert/AlertSound/heartAttackSound.mp3"),
            ]
        ),
        .testTarget(
            name: "LookheartPackageTests",
            dependencies: ["LookheartPackage"]),
    ]
)
