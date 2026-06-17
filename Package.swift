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
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.15/CometChatUIKitSwift_5_1_15.xcframework.zip",
            checksum: "da474a89188dcda8e3642067e5f3eea832996956c403c03fc7ddfbd1e1406e2b"
        )
    ]
)
