



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// Represents and wraps a method for modifying request before an image download request starts.
 protocol ImageDownloadRequestModifier {

    /// A method will be called just before the `request` being sent.
    /// This is the last chance you can modify the image download request. You can modify the request for some
    /// customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url mapping.
    ///
    /// Usually, you pass an `ImageDownloadRequestModifier` as the associated value of
    /// `CometChatKingfisherOptionsInfoItem.requestModifier` and use it as the `options` parameter in related methods.
    ///
    /// If you do nothing with the input `request` and return it as is, a downloading process will start with it.
    ///
    /// - Parameter request: The input request contains necessary information like `url`. This request is generated
    ///                      according to your resource url as a GET request.
    /// - Returns: A modified version of request, which you wish to use for downloading an image. If `nil` returned,
    ///            a `CometChatKingfisherError.requestError` with `.emptyRequest` as its reason will occur.
    ///
    func modified(for request: URLRequest) -> URLRequest?
}

/// A wrapper for creating an `ImageDownloadRequestModifier` easier.
/// This type conforms to `ImageDownloadRequestModifier` and wraps an image modify block.
 struct AnyModifier: ImageDownloadRequestModifier {
    
    let block: (URLRequest) -> URLRequest?

    /// For `ImageDownloadRequestModifier` conformation.
     func modified(for request: URLRequest) -> URLRequest? {
        return block(request)
    }
    
    /// Creates a value of `ImageDownloadRequestModifier` which runs `modify` block.
    ///
    /// - Parameter modify: The request modifying block runs when a request modifying task comes.
    ///                     The return `URLRequest?` value of this block will be used as the image download request.
    ///                     If `nil` returned, a `CometChatKingfisherError.requestError` with `.emptyRequest` as its
    ///                     reason will occur.
     init(modify: @escaping (URLRequest) -> URLRequest?) {
        block = modify
    }
}
