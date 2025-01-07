//
//  CometChatConversationEventListener.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 16/06/24.
//

import Foundation
import CometChatSDK

@objc public protocol CometChatConversationEventListener {
    
    @objc optional func ccConversationDeleted(conversation: Conversation)
    
    @available(*, deprecated, message: "Use `onTransientMessageReceived(_ message: TransientMessage)` instead")
    @objc optional func onConversationDelete(conversation: Conversation)
    
    @available(*, deprecated, message: "This method is now deprecated")
    @objc optional func onStartConversationClick()
    
}
