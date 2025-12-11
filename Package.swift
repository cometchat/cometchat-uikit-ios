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
            url: "https://library.cometchat.io/ios/v5.0/xcode16/CometChatUIKitSwift_5_1_3.xcframework.zip",
            checksum: "a6da307be9d4e5207573fdeccaf22c8f0f5f14b07624f26448e9334b0fd20135"
        )
    ]
)
