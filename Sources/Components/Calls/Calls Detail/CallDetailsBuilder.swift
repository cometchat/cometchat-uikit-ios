//
//  CallDetailsBuilder.swift
//  
//
//  Created by Ajay Verma on 09/03/23.
//

import Foundation
import CometChatSDK

enum CallDetailsBuilderResult {
    case success([BaseMessage]?)
    case failure(CometChatException)
}

public class CallDetailsBuilder {
    
    public static func getDefaultRequestBuilder() -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
            return CometChatSDK.MessagesRequest.MessageRequestBuilder().set(limit: 5).set(categories: [MessageCategoryConstants.call, MessageCategoryConstants.custom]).set(types: [MessageTypeConstants.audio, MessageTypeConstants.video, MessageTypeConstants.meeting])
        }
    
    static func fetchCalls(callsRequest: MessagesRequest,  completion: @escaping (CallDetailsBuilderResult) -> Void) {
        callsRequest.fetchPrevious { fetchedGroups in
            completion(.success(fetchedGroups))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}

