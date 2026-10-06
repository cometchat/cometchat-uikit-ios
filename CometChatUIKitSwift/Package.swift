// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CometChatUIKitSwift",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        // Both targets ship in the one product: the prebuilt UIKit binary plus a
        // wrapper target that exists only to pull in CometChatCardsSwift and
        // CometChatSDK (a binary target cannot declare dependencies itself). Linking
        // the product gives consumers both modules automatically — UIKit's public API
        // exposes their types (e.g. CometChatCardActionEvent, User), so both are
        // required to compile.
        .library(name: "CometChatUIKitSwift", targets: ["CometChatUIKitSwift", "CometChatUIKitSwiftDependencies"])
    ],
    dependencies: [
        // Floor is 1.2.0 (ENG-37757): 1.1.0 crashes at launch on iOS 16/17, and 1.1.1
        // fixed that but shipped static — which merged Cards into every consumer's link
        // and duplicated its classes. 1.2.0 ships dynamic. Raising the floor forces SPM
        // consumers whose Package.resolved still pins an older version onto the fix.
        .package(name: "CometChatCardsSwift", url: "https://github.com/cometchat/cards-sdk-ios.git", from: "1.2.0"),
        // ENG-39353: the binary imports CometChatSDK and links it strongly, so it must be
        // declared or SPM never fetches it. The floor is the version the binary is built
        // against (the exactVersion pin in CometChatUIKitSwift.xcodeproj): older 4.1.x
        // lacks API the kit calls. Not exact — both ship with library evolution, so newer
        // 4.1.x stays compatible. scripts/check-manifest-sdk-floor.sh keeps the two equal.
        // CometChatCallsSDK is deliberately NOT declared: the kit weak-links it (ENG-39340).
        .package(name: "CometChatSDK", url: "https://github.com/cometchat/chat-sdk-ios.git", from: "4.1.10")
    ],
    targets: [
        .binaryTarget(
            name: "CometChatUIKitSwift",
            url: "https://dl.cloudsmith.io/public/cometchat/cometchat/raw/versions/5.2.1/CometChatUIKitSwift_5.2.1.xcframework.zip",
            checksum: "42eb60a0478e34a99bf3ffc32b9d55570261403809f656c92fe672a3f51a7ef8"
        ),
        .target(
            name: "CometChatUIKitSwiftDependencies",
            dependencies: [
                .product(name: "CometChatCardsSwift", package: "CometChatCardsSwift"),
                .product(name: "CometChatSDK", package: "CometChatSDK")
            ],
            path: "Sources/CometChatUIKitSwiftDependencies"
        )
    ]
)
