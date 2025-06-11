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
            url: "https://library.cometchat.io/ios/v5.0/xcode16/CometChatUIKitSwift_5_0_6.xcframework.zip",
            checksum: "485be03491284d1614711fa6080aa15c5789a3b0b432d2302f47fc3a65e99521"
        )
    ]
)
