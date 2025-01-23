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
            .exact("4.0.54")
        )
    ],
    targets: [
        // Defining the binary target for CometChatUIKitSwift.
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_5_0_0_beta_2.xcframework.zip",
            checksum: "c0c644249d77963242b2cd17e10c5534d863722b8e18e70b125fc27586cfbe6d"
        )
    ]
)
