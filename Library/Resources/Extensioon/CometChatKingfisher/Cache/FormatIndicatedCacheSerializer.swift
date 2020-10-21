



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// `FormatIndicatedCacheSerializer` lets you indicate an image format for serialized caches.
///
/// It could serialize and deserialize PNG, JPEG and GIF images. For
/// image other than these formats, a normalized `pngRepresentation` will be used.
///
/// Example:
/// ````
/// let profileImageSize = CGSize(width: 44, height: 44)
///
/// // A round corner image.
/// let imageProcessor = RoundCornerImageProcessor(
///     cornerRadius: profileImageSize.width / 2, targetSize: profileImageSize)
///
/// let optionsInfo: CometChatKingfisherOptionsInfo = [
///     .cacheSerializer(FormatIndicatedCacheSerializer.png), 
///     .processor(imageProcessor)]
///
/// A URL pointing to a JPEG image.
/// let url = URL(string: "https://example.com/image.jpg")!
///
/// // Image will be always cached as PNG format to preserve alpha channel for round rectangle.
/// // So when you load it from cache again later, it will be still round cornered.
/// // Otherwise, the corner part would be filled by white color (since JPEG does not contain an alpha channel).
/// imageView.cf.setImage(with: url, options: optionsInfo)
/// ````
 struct FormatIndicatedCacheSerializer: CacheSerializer {
    
    /// A `FormatIndicatedCacheSerializer` which converts image from and to PNG format. If the image cannot be
    /// represented by PNG format, it will fallback to its real format which is determined by `original` data.
     static let png = FormatIndicatedCacheSerializer(imageFormat: .PNG)
    
    /// A `FormatIndicatedCacheSerializer` which converts image from and to JPEG format. If the image cannot be
    /// represented by JPEG format, it will fallback to its real format which is determined by `original` data.
     static let jpeg = FormatIndicatedCacheSerializer(imageFormat: .JPEG)
    
    /// A `FormatIndicatedCacheSerializer` which converts image from and to GIF format. If the image cannot be
    /// represented by GIF format, it will fallback to its real format which is determined by `original` data.
     static let gif = FormatIndicatedCacheSerializer(imageFormat: .GIF)
    
    /// The indicated image format.
    private let imageFormat: ImageFormat
    
    /// Creates data which represents the given `image` under a format.
     func data(with image: CFCrossPlatformImage, original: Data?) -> Data? {
        
        func imageData(withFormat imageFormat: ImageFormat) -> Data? {
            return autoreleasepool { () -> Data? in
                switch imageFormat {
                case .PNG: return image.cf.pngRepresentation()
                case .JPEG: return image.cf.jpegRepresentation(compressionQuality: 1.0)
                case .GIF: return image.cf.gifRepresentation()
                case .unknown: return nil
                }
            }
        }
        
        // generate data with indicated image format
        if let data = imageData(withFormat: imageFormat) {
            return data
        }
        
        let originalFormat = original?.cf.imageFormat ?? .unknown
        
        // generate data with original image's format
        if originalFormat != imageFormat, let data = imageData(withFormat: originalFormat) {
            return data
        }
        
        return original ?? image.cf.normalized.cf.pngRepresentation()
    }
    
    /// Same implementation as `DefaultCacheSerializer`.
     func image(with data: Data, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        return CometChatKingfisherWrapper.image(data: data, options: options.imageCreatingOptions)
    }
}
