



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.



import Foundation

/// Represents an image resource at a certain url and a given cache key.
/// CometChatKingfisher will use a `Resource` to download a resource from network and cache it with the cache key when
/// using `Source.network` as its image setting source.
 protocol Resource {
    
    /// The key used in cache.
    var cacheKey: String { get }
    
    /// The target image URL.
    var downloadURL: URL { get }
}

/// ImageResource is a simple combination of `downloadURL` and `cacheKey`.
/// When passed to image view set methods, CometChatKingfisher will try to download the target
/// image from the `downloadURL`, and then store it with the `cacheKey` as the key in cache.
 struct ImageResource: Resource {

    // MARK: - Initializers

    /// Creates an image resource.
    ///
    /// - Parameters:
    ///   - downloadURL: The target image URL from where the image can be downloaded.
    ///   - cacheKey: The cache key. If `nil`, CometChatKingfisher will use the `absoluteString` of `downloadURL` as the key.
    ///               Default is `nil`.
     init(downloadURL: URL, cacheKey: String? = nil) {
        self.downloadURL = downloadURL
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
    }

    // MARK: Protocol Conforming
    
    /// The key used in cache.
     let cacheKey: String

    /// The target image URL.
     let downloadURL: URL
}

/// URL conforms to `Resource` in CometChatKingfisher.
/// The `absoluteString` of this URL is used as `cacheKey`. And the URL itself will be used as `downloadURL`.
/// If you need customize the url and/or cache key, use `ImageResource` instead.
extension URL: Resource {
     var cacheKey: String { return absoluteString }
     var downloadURL: URL { return self }
}
