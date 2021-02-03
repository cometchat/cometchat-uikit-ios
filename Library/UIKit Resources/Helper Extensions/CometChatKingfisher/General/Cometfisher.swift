



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation
import ImageIO

#if os(macOS)
import AppKit
 typealias CFCrossPlatformImage = NSImage
 typealias CFCrossPlatformView = NSView
 typealias CFCrossPlatformColor = NSColor
 typealias CFCrossPlatformImageView = NSImageView
 typealias CFCrossPlatformButton = NSButton
#else
import UIKit
 typealias CFCrossPlatformImage = UIImage
 typealias CFCrossPlatformColor = UIColor
#if !os(watchOS)
 typealias CFCrossPlatformImageView = UIImageView
 typealias CFCrossPlatformView = UIView
 typealias CFCrossPlatformButton = UIButton
#else
import WatchKit
#endif
#endif

/// Wrapper for CometChatKingfisher compatible types. This type provides an extension point for
/// connivence methods in CometChatKingfisher.
 struct CometChatKingfisherWrapper<Base> {
     let base: Base
     init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with CometChatKingfisher. You can use `kf` property to get a
/// value in the namespace of CometChatKingfisher.
 protocol CometChatKingfisherCompatible: AnyObject { }

/// Represents a value type that is compatible with CometChatKingfisher. You can use `kf` property to get a
/// value in the namespace of CometChatKingfisher.
 protocol CometChatKingfisherCompatibleValue {}

extension CometChatKingfisherCompatible {
    /// Gets a namespace holder for CometChatKingfisher compatible types.
     var cf: CometChatKingfisherWrapper<Self> {
        get { return CometChatKingfisherWrapper(self) }
        set { }
    }
}

extension CometChatKingfisherCompatibleValue {
    /// Gets a namespace holder for CometChatKingfisher compatible types.
     var cf: CometChatKingfisherWrapper<Self> {
        get { return CometChatKingfisherWrapper(self) }
        set { }
    }
}

extension CFCrossPlatformImage: CometChatKingfisherCompatible { }
#if !os(watchOS)
extension CFCrossPlatformImageView: CometChatKingfisherCompatible { }
extension CFCrossPlatformButton: CometChatKingfisherCompatible { }
#else
extension WKInterfaceImage: CometChatKingfisherCompatible { }
#endif
