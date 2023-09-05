//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

extension  CometChatConversationsWithMessages: CometChatConversationEventListener {
    
    public func onConversationDelete(conversation: Conversation) {
        // called when user delete the conversation.
    }
    
    public func onStartConversationClick() {}
    
}
