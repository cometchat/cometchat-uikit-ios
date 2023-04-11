//
//  GroupsBuilder.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 18/11/22.
//

import Foundation
import CometChatPro


enum CallsBuilderResult {
    case success([BaseMessage]?)
    case failure(CometChatException)
}

public class CallsBuilder {
    
    public static let shared: CometChatPro.MessagesRequest.MessageRequestBuilder = CometChatPro.MessagesRequest.MessageRequestBuilder().set(limit: 30).set(categories: [MessageCategoryConstants.call, MessageCategoryConstants.custom]).set(types: [MessageTypeConstants.audio, MessageTypeConstants.video, MessageTypeConstants.meeting])
    
    static func getSearchBuilder(searchText: String, messageRequestBuilder: CometChatPro.MessagesRequest.MessageRequestBuilder = shared) -> CometChatPro.MessagesRequest.MessageRequestBuilder {
        return messageRequestBuilder.set(searchKeyword: searchText)
    }
    
    static func getfilteredCalls(filterCallsRequest: MessagesRequest, completion: @escaping (CallsBuilderResult) -> Void) {
        filterCallsRequest.fetchPrevious { calls in
            completion(.success(calls))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func fetchCalls(callsRequest: MessagesRequest,  completion: @escaping (CallsBuilderResult) -> Void) {
        callsRequest.fetchPrevious { fetchedGroups in
            completion(.success(fetchedGroups))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}

