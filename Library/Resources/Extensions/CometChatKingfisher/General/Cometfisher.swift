



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation
import ImageIO

#if os(macOS)
import AppKit
public typealias CFCrossPlatformImage = NSImage
public typealias CFCrossPlatformView = NSView
public typealias CFCrossPlatformColor = NSColor
public typealias CFCrossPlatformImageView = NSImageView
public typealias CFCrossPlatformButton = NSButton
#else
import UIKit
public typealias CFCrossPlatformImage = UIImage
public typealias CFCrossPlatformColor = UIColor
#if !os(watchOS)
public typealias CFCrossPlatformImageView = UIImageView
public typealias CFCrossPlatformView = UIView
public typealias CFCrossPlatformButton = UIButton
#else
import WatchKit
#endif
#endif

/// Wrapper for CometChatKingfisher compatible types. This type provides an extension point for
/// connivence methods in CometChatKingfisher.
public struct CometChatKingfisherWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with CometChatKingfisher. You can use `kf` property to get a
/// value in the namespace of CometChatKingfisher.
public protocol CometChatKingfisherCompatible: AnyObject { }

/// Represents a value type that is compatible with CometChatKingfisher. You can use `kf` property to get a
/// value in the namespace of CometChatKingfisher.
public protocol CometChatKingfisherCompatibleValue {}

extension CometChatKingfisherCompatible {
    /// Gets a namespace holder for CometChatKingfisher compatible types.
    public var cf: CometChatKingfisherWrapper<Self> {
        get { return CometChatKingfisherWrapper(self) }
        set { }
    }
}

extension CometChatKingfisherCompatibleValue {
    /// Gets a namespace holder for CometChatKingfisher compatible types.
    public var cf: CometChatKingfisherWrapper<Self> {
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
