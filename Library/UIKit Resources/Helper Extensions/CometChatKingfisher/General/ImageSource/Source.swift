



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.

import Foundation

/// Represents an image setting source for CometChatKingfisher methods.
///
/// A `Source` value indicates the way how the target image can be retrieved and cached.
///
/// - network: The target image should be got from network remotely. The associated `Resource`
///            value defines detail information like image URL and cache key.
/// - provider: The target image should be provided in a data format. Normally, it can be an image
///             from local storage or in any other encoding format (like Base64).
 enum Source {

    /// Represents the source task identifier when setting an image to a view with extension methods.
     enum Identifier {

        /// The underlying value type of source identifier.
         typealias Value = UInt
        static var current: Value = 0
        static func next() -> Value {
            current += 1
            return current
        }
    }

    // MARK: Member Cases

    /// The target image should be got from network remotely. The associated `Resource`
    /// value defines detail information like image URL and cache key.
    case network(Resource)
    
    /// The target image should be provided in a data format. Normally, it can be an image
    /// from local storage or in any other encoding format (like Base64).
    case provider(ImageDataProvider)

    // MARK: Getting Properties

    /// The cache key defined for this source value.
     var cacheKey: String {
        switch self {
        case .network(let resource): return resource.cacheKey
        case .provider(let provider): return provider.cacheKey
        }
    }

    /// The URL defined for this source value.
    ///
    /// For a `.network` source, it is the `downloadURL` of associated `Resource` instance.
    /// For a `.provider` value, it is always `nil`.
     var url: URL? {
        switch self {
        case .network(let resource): return resource.downloadURL
        // `ImageDataProvider` does not provide a URL. All it cares is how to get the data back.
        case .provider(_): return nil
        }
    }
}

extension Source {
    var asResource: Resource? {
        guard case .network(let resource) = self else {
            return nil
        }
        return resource
    }

    var asProvider: ImageDataProvider? {
        guard case .provider(let provider) = self else {
            return nil
        }
        return provider
    }
}
