



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.

import Foundation
import ImageIO

/// Represents a set of image creating options used in CometChatKingfisher.
 struct ImageCreatingOptions {

    /// The target scale of image needs to be created.
     let scale: CGFloat

    /// The expected animation duration if an animated image being created.
     let duration: TimeInterval

    /// For an animated image, whether or not all frames should be loaded before displaying.
     let preloadAll: Bool

    /// For an animated image, whether or not only the first image should be
    /// loaded as a static image. It is useful for preview purpose of an animated image.
     let onlyFirstFrame: Bool
    
    /// Creates an `ImageCreatingOptions` object.
    ///
    /// - Parameters:
    ///   - scale: The target scale of image needs to be created. Default is `1.0`.
    ///   - duration: The expected animation duration if an animated image being created.
    ///               A value less or equal to `0.0` means the animated image duration will
    ///               be determined by the frame data. Default is `0.0`.
    ///   - preloadAll: For an animated image, whether or not all frames should be loaded before displaying.
    ///                 Default is `false`.
    ///   - onlyFirstFrame: For an animated image, whether or not only the first image should be
    ///                     loaded as a static image. It is useful for preview purpose of an animated image.
    ///                     Default is `false`.
     init(
        scale: CGFloat = 1.0,
        duration: TimeInterval = 0.0,
        preloadAll: Bool = false,
        onlyFirstFrame: Bool = false)
    {
        self.scale = scale
        self.duration = duration
        self.preloadAll = preloadAll
        self.onlyFirstFrame = onlyFirstFrame
    }
}

// Represents the decoding for a GIF image. This class extracts frames from an `imageSource`, then
// hold the images for later use.
class GIFAnimatedImage {
    let images: [CFCrossPlatformImage]
    let duration: TimeInterval
    
    init?(from imageSource: CGImageSource, for info: [String: Any], options: ImageCreatingOptions) {
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [CFCrossPlatformImage]()
        var gifDuration = 0.0
        
        for i in 0 ..< frameCount {
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) else {
                return nil
            }
            
            if frameCount == 1 {
                gifDuration = .infinity
            } else {
                // Get current animated GIF frame duration
                gifDuration += GIFAnimatedImage.getFrameDuration(from: imageSource, at: i)
            }
            images.append(CometChatKingfisherWrapper.image(cgImage: imageRef, scale: options.scale, refImage: nil))
            if options.onlyFirstFrame { break }
        }
        self.images = images
        self.duration = gifDuration
    }
    
    // Calculates frame duration for a gif frame out of the kCGImagePropertyGIFDictionary dictionary.
    static func getFrameDuration(from gifInfo: [String: Any]?) -> TimeInterval {
        let defaultFrameDuration = 0.1
        guard let gifInfo = gifInfo else { return defaultFrameDuration }
        
        let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
        let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber
        let duration = unclampedDelayTime ?? delayTime
        
        guard let frameDuration = duration else { return defaultFrameDuration }
        return frameDuration.doubleValue > 0.011 ? frameDuration.doubleValue : defaultFrameDuration
    }

    // Calculates frame duration at a specific index for a gif from an `imageSource`.
    static func getFrameDuration(from imageSource: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
            as? [String: Any] else { return 0.0 }

        let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any]
        return getFrameDuration(from: gifInfo)
    }
}
