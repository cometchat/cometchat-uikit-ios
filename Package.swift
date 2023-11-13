// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwiftWrapper"])
    ],
    
    dependencies: [
        .package(name: "CometChatSDK",
            url: "https://github.com/cometchat-pro/ios-chat-sdk.git", .exact("4.0.3")
        )
    ],
    targets: [
        .target(name: "CometChatUIKitSwiftWrapper",
                dependencies: [
                    .target(name: "CometChatUIKitSwift", condition: .when(platforms: [.iOS])),
                    .product(name: "CometChatSDK", package: "CometChatSDK")
                ],
               path: "CometChatUIKitSwiftWrapper"),
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_0_3_.xcframework.zip",
            checksum: "1a8a02c7ee16d05b4f450eaaa8a4866e46310c23b4897d74980c98656db2d4d6"
        )
    ]
)
