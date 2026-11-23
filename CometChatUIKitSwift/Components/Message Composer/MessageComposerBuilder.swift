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
        // Offline ON (read once for this send): the offline send helper. The completion fires only on
        // a real success or a direct/final failure, never because a message was merely queued.
        if OfflineGate.isOn() {
            OfflineSend.send(message, quietly: true, onSent: { completion(.success($0)) }, onFailed: { completion(.failure($0)) })
            return
        }
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
    
    /// `onFirstAnswer` (offline ON only) fires when the SDK first answers the send, so a batch can
    /// send its next item without waiting for a result that, behind another unsent send, never comes.
    static func mediaMessage(message: MediaMessage, onFirstAnswer: (() -> Void)? = nil, completion: @escaping (MessageComposerBuilderResult) -> Void) {
        if OfflineGate.isOn() {
            OfflineSend.send(message, onFirstAnswer: onFirstAnswer, quietly: true, onSent: { completion(.success($0)) }, onFailed: { completion(.failure($0)) })
            return
        }
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

