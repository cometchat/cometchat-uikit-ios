//
//  CometChatConversationsWithMessages.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro

open class CometChatConversationsWithMessages: CometChatConversations {
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        
    }
    
    public override func onItemClick(conversation: Conversation, index: IndexPath?) {
        
        if let user = conversation.conversationWith as? User  {
            
            let cometChatMessages: CometChatMessages = CometChatMessages()
            cometChatMessages.set(user: user)
            if let configurations = configurations {
                cometChatMessages.set(configurations: configurations)
            }
            cometChatMessages.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cometChatMessages, animated: true)
            
            
        }else if let group = conversation.conversationWith as? Group  {
            
            let cometChatMessages: CometChatMessages = CometChatMessages()
            cometChatMessages.set(group: group)
            if let configurations = configurations {
                cometChatMessages.set(configurations: configurations)
            }
            cometChatMessages.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cometChatMessages, animated: true)
        }
    }
    
    
    
    
    
}


