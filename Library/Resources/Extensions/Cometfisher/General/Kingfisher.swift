//
//  Cometfisher.swift
//  Cometfisher
//
//  Created by Wei Wang on 16/9/14.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import ImageIO

#if os(macOS)
import AppKit
public typealias KFCrossPlatformImage = NSImage
public typealias KFCrossPlatformView = NSView
public typealias KFCrossPlatformColor = NSColor
public typealias KFCrossPlatformImageView = NSImageView
public typealias KFCrossPlatformButton = NSButton
#else
import UIKit
public typealias KFCrossPlatformImage = UIImage
public typealias KFCrossPlatformColor = UIColor
#if !os(watchOS)
public typealias KFCrossPlatformImageView = UIImageView
public typealias KFCrossPlatformView = UIView
public typealias KFCrossPlatformButton = UIButton
#else
import WatchKit
#endif
#endif

/// Wrapper for Cometfisher compatible types. This type provides an extension point for
/// connivence methods in Cometfisher.
public struct CometfisherWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with Cometfisher. You can use `kf` property to get a
/// value in the namespace of Cometfisher.
public protocol CometfisherCompatible: AnyObject { }

/// Represents a value type that is compatible with Cometfisher. You can use `kf` property to get a
/// value in the namespace of Cometfisher.
public protocol CometfisherCompatibleValue {}

extension CometfisherCompatible {
    /// Gets a namespace holder for Cometfisher compatible types.
    public var kf: CometfisherWrapper<Self> {
        get { return CometfisherWrapper(self) }
        set { }
    }
}

extension CometfisherCompatibleValue {
    /// Gets a namespace holder for Cometfisher compatible types.
    public var kf: CometfisherWrapper<Self> {
        get { return CometfisherWrapper(self) }
        set { }
    }
}

extension KFCrossPlatformImage: CometfisherCompatible { }
#if !os(watchOS)
extension KFCrossPlatformImageView: CometfisherCompatible { }
extension KFCrossPlatformButton: CometfisherCompatible { }
#else
extension WKInterfaceImage: CometfisherCompatible { }
#endif
