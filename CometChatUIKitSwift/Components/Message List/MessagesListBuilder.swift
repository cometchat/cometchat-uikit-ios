//
//  MessagesBuilder.swift
 
//
//  Created by Pushpsen Airekar on 01/12/22.
//

import Foundation
import CometChatSDK

enum MessagesListBuilderResult {
    case success([BaseMessage])
    case failure(CometChatException)
}

enum MessageActionResult {
    case success(BaseMessage)
    case failure(CometChatException)
}

public class MessagesListBuilder {
    
    public static func getDefaultRequestBuilder() -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
            return CometChatSDK.MessagesRequest.MessageRequestBuilder()
        }
    
    static func getSearchBuilder(searchText: String, messageRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder = getDefaultRequestBuilder()) -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
        return messageRequestBuilder.set(searchKeyword: searchText)
    }
    
    static func fetchPreviousMessages(messageRequest: MessagesRequest, completion: @escaping (MessagesListBuilderResult) -> Void) {
        messageRequest.fetchPrevious { messages in
            guard let messages = messages else { return }
            completion(.success(messages))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func fetchNextMessages(messageRequest: MessagesRequest, completion: @escaping (MessagesListBuilderResult) -> Void) {
        messageRequest.fetchNext { messages in
            guard let messages = messages else { return }
            completion(.success(messages))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func getfilteredMessages(filterMessageRequest: MessagesRequest, completion: @escaping (MessagesListBuilderResult) -> Void) {
        filterMessageRequest.fetchPrevious { messages in
            guard let messages = messages else { return }
            completion(.success(messages))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func editMessage(message: BaseMessage, completion: @escaping (MessageActionResult) -> Void) {
        CometChat.edit(message: message) { editedMessage in
            completion(.success(editedMessage))
        } onError: { error in
            completion(.failure(error))
        }
    }
    
    static func deleteMessage(message: BaseMessage, completion: @escaping (MessageActionResult) -> Void) {
        CometChat.delete(messageId: message.id) { deletedMessage in
            completion(.success(deletedMessage))
        } onError: { error in
            completion(.failure(error))
        }
    }
    
}
