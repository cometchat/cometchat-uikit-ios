//
//  NetworkUtils.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/01/24.
//

import Foundation


class NetworkUtils {

    /// Test seam. Inside `$requestInterceptor.withValue(hook) { … }` a request is
    /// handed to `hook` instead of `URLSession` and `completion` never fires, so the
    /// payload an interactive action builds can be asserted without a network. Task-local
    /// so parallel suites cannot see each other's hook. Never bound from product code.
    @TaskLocal static var requestInterceptor: ((_ url: String, _ method: HttpMethodType,
                                                _ header: [String: String], _ body: [String: Any]) -> Void)?

    static func requestData(url: String, method: HttpMethodType, header: [String: String], body: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let interceptor = requestInterceptor {
            interceptor(url, method, header, body)
            return
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.value
        request.allHTTPHeaderFields = header

        if !body.isEmpty {
            let jsonData = try! JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
    
}
