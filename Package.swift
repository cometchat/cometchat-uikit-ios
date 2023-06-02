// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CometChatUIKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "CometChatUIKit", targets: ["CometChatUIKit"])
    ],
    
    dependencies: [
        .package(name: "CometChatPro",
            url: "https://github.com/cometchat-pro/ios-chat-sdk.git", .exact("3.0.914")
        ),
    ],
    targets: [
        .target(name: "CometChatUIKit", dependencies: ["CometChatPro"],
                path:  "./Sources/Components" ,
                resources: [.process("Resources"),
                            .process("Shared/Resources"),
                            .process("Calls/Resources")])
       ,
    ]
)
