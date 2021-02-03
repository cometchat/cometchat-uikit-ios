



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.



import Foundation

/// An `CacheSerializer` is used to convert some data to an image object after
/// retrieving it from disk storage, and vice versa, to convert an image to data object
/// for storing to the disk storage.
 protocol CacheSerializer {
    
    /// Gets the serialized data from a provided image
    /// and optional original data for caching to disk.
    ///
    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    func data(with image: CFCrossPlatformImage, original: Data?) -> Data?

    /// Gets an image from provided serialized data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: The parsed options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    func image(with data: Data, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage?
    
    /// Gets an image deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    /// - Note:
    /// This method is deprecated. Please implement the version with
    /// `CometChatKingfisherParsedOptionsInfo` as parameter instead.
    @available(*, deprecated,
    message: "Deprecated. Implement the method with same name but with `CometChatKingfisherParsedOptionsInfo` instead.")
    func image(with data: Data, options: CometChatKingfisherOptionsInfo?) -> CFCrossPlatformImage?
}

extension CacheSerializer {
     func image(with data: Data, options: CometChatKingfisherOptionsInfo?) -> CFCrossPlatformImage? {
        return image(with: data, options: CometChatKingfisherParsedOptionsInfo(options))
    }
}

/// Represents a basic and default `CacheSerializer` used in CometChatKingfisher disk cache system.
/// It could serialize and deserialize images in PNG, JPEG and GIF format. For
/// image other than these formats, a normalized `pngRepresentation` will be used.
 struct DefaultCacheSerializer: CacheSerializer {
    
    /// The default general cache serializer used across CometChatKingfisher's cache.
     static let default1 = DefaultCacheSerializer()
    private init() {}
    
    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    ///
    /// - Note:
    /// Only when `original` contains valid PNG, JPEG and GIF format data, the `image` will be
    /// converted to the corresponding data type. Otherwise, if the `original` is provided but it is not
    /// If `original` is `nil`, the input `image` will be encoded as PNG data.
     func data(with image: CFCrossPlatformImage, original: Data?) -> Data? {
        return image.cf.data(format: original?.cf.imageFormat ?? .unknown)
    }
    
    /// Gets an image deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
     func image(with data: Data, options: CometChatKingfisherParsedOptionsInfo) -> CFCrossPlatformImage? {
        return CometChatKingfisherWrapper.image(data: data, options: options.imageCreatingOptions)
    }
}
