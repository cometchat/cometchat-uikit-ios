//
//  File.swift
//  
//
//  Created by Ajay Verma on 22/12/22.
//

import Foundation
import CometChatSDK

enum MessageComposerBuilderResult {
    case success(BaseMessage)
    case failure(CometChatException)
}

public class MessageComposerBuilder {
    static func textMessage(message: TextMessage, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        CometChat.sendTextMessage(message: message) { updatedTextMessage in
            completion(.success(updatedTextMessage))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func mediaMessage(message: MediaMessage, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        CometChat.sendMediaMessage(message: message)  { updatedMediaMessage in
            completion(.success(updatedMediaMessage))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func editMessage(message: TextMessage, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        CometChat.edit(message: message) { updateTextMessage in
            completion(.success(updateTextMessage))
        } onError: { error in
            completion(.failure(error))
        }
    }
    
}

