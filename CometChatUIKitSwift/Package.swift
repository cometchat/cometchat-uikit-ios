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
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/v5.1.13/CometChatUIKitSwift_5_1_13.xcframework.zip",
            checksum: "c72603a4136f2f006ca876037834bc09e58b8e4d77f55b042919e332d59afcfe"
        )
    ]
)
