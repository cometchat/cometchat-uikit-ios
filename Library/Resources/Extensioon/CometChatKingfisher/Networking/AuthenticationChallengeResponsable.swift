



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// Protocol indicates that an authentication challenge could be handled.
 protocol AuthenticationChallengeResponsable: AnyObject {

    /// Called when a session level authentication challenge is received.
    /// This method provide a chance to handle and response to the authentication
    /// challenge before downloading could start.
    ///
    /// - Parameters:
    ///   - downloader: The downloader which receives this challenge.
    ///   - challenge: An object that contains the request for authentication.
    ///   - completionHandler: A handler that your delegate method must call.
    ///
    /// - Note: This method is a forward from `URLSessionDelegate.urlSession(:didReceiveChallenge:completionHandler:)`.
    ///         Please refer to the document of it in `URLSessionDelegate`.
    func downloader(
        _ downloader: ImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Called when a task level authentication challenge is received.
    /// This method provide a chance to handle and response to the authentication
    /// challenge before downloading could start.
    ///
    /// - Parameters:
    ///   - downloader: The downloader which receives this challenge.
    ///   - task: The task whose request requires authentication.
    ///   - challenge: An object that contains the request for authentication.
    ///   - completionHandler: A handler that your delegate method must call.
    func downloader(
        _ downloader: ImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

extension AuthenticationChallengeResponsable {

     func downloader(
        _ downloader: ImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trustedHosts = downloader.trustedHosts, trustedHosts.contains(challenge.protectionSpace.host) {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, credential)
                return
            }
        }

        completionHandler(.performDefaultHandling, nil)
    }

     func downloader(
        _ downloader: ImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        completionHandler(.performDefaultHandling, nil)
    }

}
