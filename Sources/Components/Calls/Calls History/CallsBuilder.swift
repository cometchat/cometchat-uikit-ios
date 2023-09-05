//
//  GroupsBuilder.swift
 
//
//  Created by Pushpsen Airekar on 18/11/22.
//

import Foundation
import CometChatSDK


enum CallsBuilderResult {
    case success([BaseMessage]?)
    case failure(CometChatException)
}

public class CallsBuilder {
    
    public static func getDefaultRequestBuilder() -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
        return CometChatSDK.MessagesRequest.MessageRequestBuilder().set(limit: 30).set(categories: [MessageCategoryConstants.call, MessageCategoryConstants.custom]).set(types: [MessageTypeConstants.audio, MessageTypeConstants.video, MessageTypeConstants.meeting])
    }
    
    static func getSearchBuilder(searchText: String, messageRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder = getDefaultRequestBuilder()) -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
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

