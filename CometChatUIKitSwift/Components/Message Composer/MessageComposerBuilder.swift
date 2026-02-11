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
            // iOS 26 fix: Ensure callback is delivered on main thread
            // The SDK may deliver callbacks on background threads in iOS 26
            if Thread.isMainThread {
                completion(.success(updatedTextMessage))
            } else {
                DispatchQueue.main.async {
                    completion(.success(updatedTextMessage))
                }
            }
        } onError: { error in
            guard let error = error else { return }
            // iOS 26 fix: Ensure callback is delivered on main thread
            if Thread.isMainThread {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func mediaMessage(message: MediaMessage, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        CometChat.sendMediaMessage(message: message)  { updatedMediaMessage in
            // iOS 26 fix: Ensure callback is delivered on main thread
            if Thread.isMainThread {
                completion(.success(updatedMediaMessage))
            } else {
                DispatchQueue.main.async {
                    completion(.success(updatedMediaMessage))
                }
            }
        } onError: { error in
            guard let error = error else { return }
            // iOS 26 fix: Ensure callback is delivered on main thread
            if Thread.isMainThread {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func editMessage(message: TextMessage, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        CometChat.edit(message: message) { updateTextMessage in
            // iOS 26 fix: Ensure callback is delivered on main thread
            if Thread.isMainThread {
                completion(.success(updateTextMessage))
            } else {
                DispatchQueue.main.async {
                    completion(.success(updateTextMessage))
                }
            }
        } onError: { error in
            // iOS 26 fix: Ensure callback is delivered on main thread
            if Thread.isMainThread {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
}

