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
        // Floor is 1.2.0 (ENG-37757): 1.1.0 crashes at launch on iOS 16/17, and 1.1.1
        // fixed that but shipped static — which merged Cards into every consumer's link
        // and duplicated its classes. 1.2.0 ships dynamic. Raising the floor forces SPM
        // consumers whose Package.resolved still pins an older version onto the fix.
        .package(name: "CometChatCardsSwift", url: "https://github.com/cometchat/cards-sdk-ios.git", from: "1.2.0")
    ],
    targets: [
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.22/CometChatUIKitSwift_5.1.22.xcframework.zip",
            checksum: "4e628209be12357e4aea082c4ef654637e2915fc7b00f6cc2ef3c2c398278e15"
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
