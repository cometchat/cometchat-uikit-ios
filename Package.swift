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
            url: "https://github.com/cometchat/chat-sdk-ios.git", .exact("4.0.48")
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
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_3_10.xcframework.zip",
            checksum: "8ea6444c27c022e5b55a979b25e4d3a25f1519a2ed094fba1d68c9073d83de4a"
        )
    ]
)
