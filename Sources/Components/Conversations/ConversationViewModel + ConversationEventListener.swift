//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatConversationEventListener {
    
    func onConversationDelete(conversation: Conversation) {
        //update(conversation: conversation)
        print("ConversationsViewModel - events - onConversationDelete")
    }
    
    func onStartConversationClick() {
        
        print("ConversationsViewModel - events - onStartConversationClick")
    }
    
}
