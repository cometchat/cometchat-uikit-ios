// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // This defines the library that will be used by the consumers of your SPM package.
        .library(
            name: "CometChatUIKitSwift",
            targets: ["CometChatUIKitSwift"]
        )
    ],
    dependencies: [
        // Adding the CometChatSDK dependency.
        .package(
            name: "CometChatSDK",
            url: "https://github.com/cometchat/chat-sdk-ios.git",
            .exact("4.0.55")
        )
    ],
    targets: [
        // Defining the binary target for CometChatUIKitSwift.
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_5_0_0_beta.4_.xcframework.zip",
            checksum: "e0a56d7f2a541e74da7b55d6bb6cd6378d1f3e34441a3057962a9f62e48261fc"
        )
    ]
)
