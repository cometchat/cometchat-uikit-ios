//
//  NetworkUtils.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/01/24.
//

import Foundation


class NetworkUtils {

    static func requestData(url: String, method: HttpMethodType, header: [String: String], body: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
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
