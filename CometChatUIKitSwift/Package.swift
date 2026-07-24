// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        // Both targets ship in the one product: the prebuilt UIKit binary plus a
        // wrapper target that exists only to pull in CometChatCardsSwift (a binary
        // target cannot declare dependencies itself). Linking the product gives
        // consumers the Cards module automatically — UIKit's public API exposes
        // Cards types (e.g. CometChatCardActionEvent), so it is required to compile.
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwift", "CometChatUIKitSwiftDependencies"])
    ],
    dependencies: [
        .package(name: "CometChatCardsSwift", url: "https://github.com/cometchat/cards-sdk-ios.git", from: "1.1.0")
    ],
    targets: [
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.17/CometChatUIKitSwift_5.1.17.xcframework.zip",
            checksum: "dcfd1c45882c8a719aa651f771ca73f3e6e5d382557564a35edf6ef97c08195e"
        ),
        .target(
            name: "CometChatUIKitSwiftDependencies",
            dependencies: [
                .product(name: "CometChatCardsSwift", package: "CometChatCardsSwift")
            ],
            path: "Sources/CometChatUIKitSwiftDependencies"
        )
    ]
)
