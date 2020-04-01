



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.



import Foundation

/// Represents a data provider to provide image data to CometChatKingfisher when setting with
/// `Source.provider` source. Compared to `Source.network` member, it gives a chance
/// to load some image data in your own way, as long as you can provide the data
/// representation for the image.
public protocol ImageDataProvider {
    
    /// The key used in cache.
    var cacheKey: String { get }
    
    /// Provides the data which represents image. CometChatKingfisher uses the data you pass in the
    /// handler to process images and caches it for later use.
    ///
    /// - Parameter handler: The handler you should call when you prepared your data.
    ///                      If the data is loaded successfully, call the handler with
    ///                      a `.success` with the data associated. Otherwise, call it
    ///                      with a `.failure` and pass the error.
    ///
    /// - Note:
    /// If the `handler` is called with a `.failure` with error, a `dataProviderError` of
    /// `ImageSettingErrorReason` will be finally thrown out to you as the `CometChatKingfisherError`
    /// from the framework.
    func data(handler: @escaping (Result<Data, Error>) -> Void)
}

/// Represents an image data provider for loading from a local file URL on disk.
/// Uses this type for adding a disk image to CometChatKingfisher. Compared to loading it
/// directly, you can get benefit of using CometChatKingfisher's extension methods, as well
/// as applying `ImageProcessor`s and storing the image to `ImageCache` of CometChatKingfisher.
public struct LocalFileImageDataProvider: ImageDataProvider {

    // MARK: Public Properties

    /// The file URL from which the image be loaded.
    public let fileURL: URL

    // MARK: Initializers

    /// Creates an image data provider by supplying the target local file URL.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL from which the image be loaded.
    ///   - cacheKey: The key is used for caching the image data. By default,
    ///               the `absoluteString` of `fileURL` is used.
    public init(fileURL: URL, cacheKey: String? = nil) {
        self.fileURL = fileURL
        self.cacheKey = cacheKey ?? fileURL.absoluteString
    }

    // MARK: Protocol Conforming

    /// The key used in cache.
    public var cacheKey: String

    public func data(handler: (Result<Data, Error>) -> Void) {
        handler(Result(catching: { try Data(contentsOf: fileURL) }))
    }
}

/// Represents an image data provider for loading image from a given Base64 encoded string.
public struct Base64ImageDataProvider: ImageDataProvider {

    // MARK: Public Properties
    /// The encoded Base64 string for the image.
    public let base64String: String

    // MARK: Initializers

    /// Creates an image data provider by supplying the Base64 encoded string.
    ///
    /// - Parameters:
    ///   - base64String: The Base64 encoded string for an image.
    ///   - cacheKey: The key is used for caching the image data. You need a different key for any different image.
    public init(base64String: String, cacheKey: String) {
        self.base64String = base64String
        self.cacheKey = cacheKey
    }

    // MARK: Protocol Conforming

    /// The key used in cache.
    public var cacheKey: String

    public func data(handler: (Result<Data, Error>) -> Void) {
        let data = Data(base64Encoded: base64String)!
        handler(.success(data))
    }
}

/// Represents an image data provider for a raw data object.
public struct RawImageDataProvider: ImageDataProvider {

    // MARK: Public Properties

    /// The raw data object to provide to CometChatKingfisher image loader.
    public let data: Data

    // MARK: Initializers

    /// Creates an image data provider by the given raw `data` value and a `cacheKey` be used in CometChatKingfisher cache.
    ///
    /// - Parameters:
    ///   - data: The raw data reprensents an image.
    ///   - cacheKey: The key is used for caching the image data. You need a different key for any different image.
    public init(data: Data, cacheKey: String) {
        self.data = data
        self.cacheKey = cacheKey
    }

    // MARK: Protocol Conforming
    
    /// The key used in cache.
    public var cacheKey: String

    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        handler(.success(data))
    }
}
