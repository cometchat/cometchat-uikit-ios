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
            url: "https://github.com/cometchat-pro/ios-chat-sdk.git", .exact("4.0.4")
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
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_1_0.xcframework.zip",
            checksum: "4b57ceaadd069d7c591fa876202f8070edebaa3ab8d5277d9a9e96f69da38c76"
        )
    ]
)
