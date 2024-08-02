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
            url: "https://github.com/cometchat/chat-sdk-ios.git", .exact("4.0.52")
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
            url: "https://library.cometchat.io/ios/v4.0/xcode15/CometChatUIKitSwift_4_3_15.xcframework.zip",
            checksum: "853858b2bbbd7b32ce3196b4fd74c832094a385adc18710d13cece2dda09f762"
        )
    ]
)
