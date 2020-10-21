//
//  ImageModifier.swift

//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//
//  Created by Ethan Gill on 2017/11/28.
//
//  Copyright (c) 2020 Ethan Gill <ethan.gill@me.com>
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

/// An `ImageModifier` can be used to change properties on an image in between
/// cache serialization and use of the image. The modified returned image will be
/// only used for current rendering purpose, the serialization data will not contain
/// the changes applied by the `ImageModifier`.
 protocol ImageModifier {
    /// Modify an input `Image`.
    ///
    /// - parameter image:   Image which will be modified by `self`
    ///
    /// - returns: The modified image.
    ///
    /// - Note: The return value will be unmodified if modifying is not possible on
    ///         the current platform.
    /// - Note: Most modifiers support UIImage or NSImage, but not CGImage.
    func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage
}

/// A wrapper for creating an `ImageModifier` easier.
/// This type conforms to `ImageModifier` and wraps an image modify block.
/// If the `block` throws an error, the original image will be used.
 struct AnyImageModifier: ImageModifier {

    /// A block which modifies images, or returns the original image
    /// if modification cannot be performed with an error.
    let block: (CFCrossPlatformImage) throws -> CFCrossPlatformImage

    /// Creates an `AnyImageModifier` with a given `modify` block.
     init(modify: @escaping (CFCrossPlatformImage) throws -> CFCrossPlatformImage) {
        block = modify
    }

    /// Modify an input `Image`. See `ImageModifier` protocol for more.
     func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage {
        return (try? block(image)) ?? image
    }
}


import UIKit

/// Modifier for setting the rendering mode of images.
 struct RenderingModeImageModifier: ImageModifier {

    /// The rendering mode to apply to the image.
     let renderingMode: UIImage.RenderingMode

    /// Creates a `RenderingModeImageModifier`.
    ///
    /// - Parameter renderingMode: The rendering mode to apply to the image. Default is `.automatic`.
     init(renderingMode: UIImage.RenderingMode = .automatic) {
        self.renderingMode = renderingMode
    }

    /// Modify an input `Image`. See `ImageModifier` protocol for more.
     func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage {
        return image.withRenderingMode(renderingMode)
    }
}

/// Modifier for setting the `flipsForRightToLeftLayoutDirection` property of images.
 struct FlipsForRightToLeftLayoutDirectionImageModifier: ImageModifier {

    /// Creates a `FlipsForRightToLeftLayoutDirectionImageModifier`.
     init() {}

    /// Modify an input `Image`. See `ImageModifier` protocol for more.
     func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage {
        return image.imageFlippedForRightToLeftLayoutDirection()
    }
}

/// Modifier for setting the `alignmentRectInsets` property of images.
 struct AlignmentRectInsetsImageModifier: ImageModifier {

    /// The alignment insets to apply to the image
     let alignmentInsets: UIEdgeInsets

    /// Creates an `AlignmentRectInsetsImageModifier`.
     init(alignmentInsets: UIEdgeInsets) {
        self.alignmentInsets = alignmentInsets
    }

    /// Modify an input `Image`. See `ImageModifier` protocol for more.
     func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage {
        return image.withAlignmentRectInsets(alignmentInsets)
    }
}

