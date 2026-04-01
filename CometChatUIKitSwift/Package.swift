// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwift"])
    ],
    targets: [
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.12/CometChatUIKitSwift_5_1_12.xcframework.zip",
            checksum: "f57b8c0a3db26bd50838914f068b5c4810ba40403f21dd06d9c0b848acdae003"
        )
    ]
)
