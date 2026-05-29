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
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.1.14/CometChatUIKitSwift_5_1_14.xcframework.zip",
            checksum: "fffb26c97f09e04f1fac19e1e1e40261de40b8d100ab363c01ea8397b86f2eeb"
        )
    ]
)
