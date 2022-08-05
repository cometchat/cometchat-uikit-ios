//
//  CometChatHelper.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 27/06/22.
//

import Foundation
import CometChatPro

final public class CometChatUIHelper {
    
    public static func onMessageSent(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        CometChatMessageEvents.emitOnMessageSent(message: message, status: status)
    }
    
    public static func onMessageError(message: BaseMessage, error: CometChatException) {
        CometChatMessageEvents.emitOnError(message: message, error: error)
    }

    public static func onMessageEdit(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        CometChatMessageEvents.emitOnMessageEdit(message: message, status: status)
    }

    public static func onMessageDelete(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        CometChatMessageEvents.emitOnMessageDelete(message: message, status: status)
    }

    public static func onMessageReply(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        CometChatMessageEvents.emitOnMessageReply(message: message, status: status)
    }

    public static func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        CometChatMessageEvents.emitOnMessageReact(message: message, reaction: reaction)
    }
}
