//
//  NotificationFeedBuilder.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import Foundation
import CometChatSDK

enum NotificationFeedBuilderResult {
    case success([NotificationFeedItem])
    case failure(CometChatException)
}

enum NotificationCategoriesBuilderResult {
    case success([NotificationCategory])
    case failure(CometChatException)
}

/// Wraps SDK request builders for the Notification Feed component.
public class NotificationFeedBuilder {
    
    public static func getDefaultFeedRequestBuilder() -> NotificationFeedRequest.NotificationFeedRequestBuilder {
        return NotificationFeedRequest.NotificationFeedRequestBuilder()
            .set(limit: 20)
    }
    
    public static func getDefaultCategoriesRequestBuilder() -> NotificationCategoriesRequest.NotificationCategoriesRequestBuilder {
        return NotificationCategoriesRequest.NotificationCategoriesRequestBuilder()
            .set(limit: 50)
    }
    
    static func fetchFeedItems(request: NotificationFeedRequest, completion: @escaping (NotificationFeedBuilderResult) -> Void) {
        request.fetchNext(onSuccess: { feedItems in
            completion(.success(feedItems))
        }, onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        })
    }
    
    static func fetchCategories(request: NotificationCategoriesRequest, completion: @escaping (NotificationCategoriesBuilderResult) -> Void) {
        request.fetchNext(onSuccess: { categories in
            completion(.success(categories))
        }, onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        })
    }
}
