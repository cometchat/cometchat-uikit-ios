// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwift"])
    ],
    targets: [
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.16/CometChatUIKitSwift_5_1_16.xcframework.zip",
            checksum: "9bdcfda40575efd4532094dfb72d7a12552c6b41692c21a556ea707459bd7073"
        )
    ]
)
