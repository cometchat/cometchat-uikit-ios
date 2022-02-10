// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-swift-chat-ui-kit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ios-swift-chat-ui-kit",
            targets: ["ios-swift-chat-ui-kit"]),
    ],
    dependencies: [
        .package(
            name: "CometChatPro",
            url: "https://github.com/cometchat-pro/ios-chat-sdk.git",
            from: "3.0.9"
        )
    ],
    targets: [
        .target(
            name: "ios-swift-chat-ui-kit",
            dependencies: ["CometChatPro"],
            path:  "./Sources/CometChatWorkspace")
    ]
)
