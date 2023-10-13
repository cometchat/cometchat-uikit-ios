// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwift"])
    ],
    
    dependencies: [
        .package(name: "CometChatSDK",
            url: "https://github.com/cometchat-pro/ios-chat-sdk.git", .exact("4.0.2")
        ),
    ],
    targets: [
        .target(name: "CometChatUIKitSwift", dependencies: ["CometChatSDK"],
                path:  "./Sources/Components" ,
                resources: [.process("Resources"),
                            .process("Shared/Resources"),
                            .process("Calls/Resources")])
    ]
)
