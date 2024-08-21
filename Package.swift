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
            url: "https://github.com/cometchat/chat-sdk-ios.git", .exact("4.0.53")
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
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_3_17.xcframework.zip",
            checksum: "0eaaa1774802a4affb809bd4d1c6fcc94ac453a8072f73f0501f1e6b0fc99b63"
        )
    ]
)
