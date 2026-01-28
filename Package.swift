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
            .exact("4.0.73")
        )
    ],
    targets: [
        // Defining the binary target for CometChatUIKitSwift.
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://library.cometchat.io/ios/v5.0/xcode16/CometChatUIKitSwift_5_1_6.xcframework.zip",
            checksum: "66cdfedb13cefa48a223ced54d1d464f9b2454ed19eb8b7a70fdc9280b8f3149"
        )
    ]
)
