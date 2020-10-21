



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// Represents and wraps a method for modifying request during an image download request redirection.
 protocol ImageDownloadRedirectHandler {

    /// The `ImageDownloadRedirectHandler` contained will be used to change the request before redirection.
    /// This is the posibility you can modify the image download request during redirection. You can modify the
    /// request for some customizing purpose, such as adding auth token to the header, do basic HTTP auth or
    /// something like url mapping.
    ///
    /// Usually, you pass an `ImageDownloadRedirectHandler` as the associated value of
    /// `CometChatKingfisherOptionsInfoItem.redirectHandler` and use it as the `options` parameter in related methods.
    ///
    /// If you do nothing with the input `request` and return it as is, a downloading process will redirect with it.
    ///
    /// - Parameters:
    ///   - task: The current `SessionDataTask` which triggers this redirect.
    ///   - response: The response received during redirection.
    ///   - newRequest: The request for redirection which can be modified.
    ///   - completionHandler: A closure for being called with modified request.
    func handleHTTPRedirection(
        for task: SessionDataTask,
        response: HTTPURLResponse,
        newRequest: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
}

/// A wrapper for creating an `ImageDownloadRedirectHandler` easier.
/// This type conforms to `ImageDownloadRedirectHandler` and wraps a redirect request modify block.
 struct AnyRedirectHandler: ImageDownloadRedirectHandler {
    
    let block: (SessionDataTask, HTTPURLResponse, URLRequest, (URLRequest?) -> Void) -> Void

     func handleHTTPRedirection(
        for task: SessionDataTask,
        response: HTTPURLResponse,
        newRequest: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        block(task, response, newRequest, completionHandler)
    }
    
    /// Creates a value of `ImageDownloadRedirectHandler` which runs `modify` block.
    ///
    /// - Parameter modify: The request modifying block runs when a request modifying task comes.
    ///
     init(handle: @escaping (SessionDataTask, HTTPURLResponse, URLRequest, (URLRequest?) -> Void) -> Void) {
        block = handle
    }
}
