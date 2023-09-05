//
//  ConversationsBuilder.swift
//  
//
//  Created by Abdullah Ansari on 24/11/22.
//

import Foundation
import CometChatSDK

enum ConverstionsBuilderResult {
    case success([Conversation])
    case failure(CometChatException)
}

public class ConversationsBuilder {
    
    public static func getDefaultRequestBuilder() -> CometChatSDK.ConversationRequest.ConversationRequestBuilder {
            return CometChatSDK.ConversationRequest.ConversationRequestBuilder(limit: 30)
        }
    
    static func fetchConversation(conversationRequest: ConversationRequest, completion: @escaping (ConverstionsBuilderResult) -> Void) {
        conversationRequest.fetchNext { fetchedConversation in
            completion(.success(fetchedConversation))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func getRefreshConversation(conversationsRequest: ConversationRequest, completion: @escaping (ConverstionsBuilderResult) -> Void) {
        conversationsRequest.fetchNext { conversations in
            completion(.success(conversations))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
}
